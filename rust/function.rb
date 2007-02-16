# Copyright (c) 2005-2007 Diego Pettenò <flameeyes@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'set'
require 'rust/element'

module Rust
  # This class represent an abstracted bound function; it is not
  # supposed to be used directly, instead its subclass should be used,
  # like CxxClass::Method.
  class Function < Element
    # Class representing a function or method parameter
    class Parameter

      attr_reader :type, :name, :optional

      def initialize(type, name, optional) #:notnew:
        @type = type
        @name = name
        @optional = optional
      end

      # Returns the C/C++ call to convert the (named) parameter from its
      # ruby value to the C/C++ corresponding variable
      def conversion
        return internal_conversion(@name)
      end

      # Returns the C/C++ call to convert the (indexed) parameter from
      # its ruby value to the C/C++ corresponding variable, for
      # variable-argument function calls.
      def index_conversion(index)
        raise TypeError, "index not an integer" if index.class != Fixnum
        return internal_conversion("argv[#{index}]")
      end

      # Internal conversion funciton used by Parameter.conversion
      # and Parameter.index_conversion public functions.
      def internal_conversion(variable)
        "ruby2#{@type.sub("*", "Ptr").gsub("::", "_").gsub(' ', '')}(#{variable})"
      end
      private :internal_conversion

    end

    # This class describes a parameter with a default value: this
    # creates a variable-argument function, where this parameter can
    # be skipped. If missing, the default value will be used.
    class DefaultParameter < Parameter
      attr_reader :default

      def initialize(type, name, value)
        super(type, name, false)
        
        @default = value
      end
    end

    # This class describe a parameter that is given a constant value:
    # such a parameter won't be available on the Ruby side of the
    # interface, instead it will be replaced during call with a
    # constant value. Note that the constant might as well be the
    # value of a variable available in the scope of the function call
    # (i.e. the instance pointer (tmp) or the name of another parameter).
    class ConstantParameter < Parameter
      attr_reader :default

      def initialize(type, name, value)
        super(type, name, false)

        @value = value
      end
    end

    attr_reader :varname

    # Initialisation function, sets the important parameters from the
    # params hash provided, and the derived information that are needed.
    def initialize(params) # :notnew:
      super()

      @return = params[:return]
      @name = params[:name]
      @bindname = params[:bindname]
      @parent = params[:parent]

      @varname = "f#{@name}"

      @aliases = Set.new
      @parameters = Array.new
      @variable = false # Variable arguments function

      nocamel_bindname = @bindname.gsub(/([^A-Z])([A-Z])([^A-Z])/) do
        |letter| "#{$1}_#{$2.downcase}#{$3}"
      end
      
      @aliases << nocamel_bindname unless nocamel_bindname == @bindname

      @declaration_template = "!function_prototype!;\n"
      @definition_template = Templates["FunctionDefinition"]
      @prototype_template = "VALUE !function_varname! ( VALUE self !function_parameters! )"
      @initialization_template = Templates["FunctionInitBinding"]

      add_expansion 'function_aliases', '@aliases.collect { |alii| Templates["FunctionInitAlias"].gsub("!function_alias!", alii) }.join("\n")'
      add_expansion 'function_prototype', '@prototype_template'
      add_expansion 'function_parameters', '@parameters.collect { |p| ", VALUE #{p.name}" }.join'
      add_expansion 'function_call', 'stub'
      add_expansion 'function_varname', 'varname'
      add_expansion 'function_cname', '@name'
      add_expansion 'function_paramcount', 'paramcount'
      add_expansion 'function_bindname', '@bindname'
      add_expansion 'parent_varname', '@parent.varname'
    end

    # Adds an alias for the function.
    # The same C++ function can be bound with more than one name,
    # as CamelCase names in the methods are bound also  with
    # ruby_style names, so that the users can choose what to use.
    def add_alias(name)
      @aliases << name
      
      nocamel_alias = name.gsub(/([^A-Z])([A-Z])([^A-Z])/) do
        |letter| "#{$1}_#{$2.downcase}#{$3}"
      end
      
      @aliases << nocamel_alias unless nocamel_alias == name
    end

    # Adds a new parameter to the function
    def add_parameter(name, type, optional = false)
      param = Parameter.new(name, type, optional)
      @parameters << param

      if optional
        @variable = true 
        @prototype_template = "VALUE !function_varname! ( int argc, VALUE *argv, VALUE self )"
      end

      return param
    end

    # Adds a parameter with a default value.
    # See Rust::Function::DefaultParameter
    def add_parameter_default(name, type, value)
      @variable = true
      @prototype_template = "VALUE !function_varname! ( int argc, VALUE *argv, VALUE self )"

      param = DefaultParameter.new(name, type, value)

      @parameters << param

      return param
    end

    # Adds a constant parameter, see Rust::Function::ConstantParameter
    def add_constant_parameter(name, type, value)
      param = ConstantParameter.new(name, type, value)

      @parameters << param

      return param
    end

    # Set different, non-default templates for functions, that can be used
    # when many functions of the bound C/C++ library contains functions
    # that require to be handled in a particular way.
    def set_custom(prototype, definition)
      @definition_template = definition
      @prototype_template = prototype
    end

    # Gets the parameters' count. For variable-arguments functions,
    # this returns -1, while for other functions the count depends on
    # the parameters added, as there might be parameters which are
    # passed constant values (e.g. the instance parameter for class
    # wrappers), that are not counted for Ruby-side parameters count.
    def paramcount
      return -1 if @variable

      paramcount = 0
      @parameters.each do |param|
        paramcount = paramcount +1 unless param.respond_to?("value")
      end

      return paramcount
    end

    # Returns an array of the valid cases for variable-argument calls.
    # For instance, a function might need _at least_ three parameters,
    # and can accept _up to_ nine parameters. In that case the range
    # would be 3..9.
    # The upper boundary is always the same of paramcount, while the
    # lower depends on the first optional parameter found. Parameters
    # with default are like optional parameters.
    def arguments_range
      lower_bound = 0
      @parameters.each do |param|
        break if (param.respond_to?("default") or param.optional)

        lower_bound = lower_bound +1
      end

      return lower_bound..paramcount
    end

    def params_conversion(nparams = nil)
      return if @parameters.empty?

      variable_arguments = nparams != nil
      nparams = paramcount unless nparams
      
      ret = ""
      index = 0
      @parameters.each do |param|
        # If we're done with the parameters requested, then we're in
        # the extra loops, which means we break out unless the current
        # parameter is a default parameter or a constant parameter.
        break unless index < nparams or
          param.respond_to?("default") or
          param.respond_to?("value")

        ret << "," if index > 0

        case
        when (index < nparams and not variable_arguments)
          ret << param.conversion
          index = index +1 # Only increment for ruby parameters consumed
        when (index < nparams and variable_arguments)
          ret << param.index_conversion(index)
          index = index +1 # Only increment for ruby parameters consumed
        when param.respond_to?("default")
          ret << param.default
        when param.respond_to?("value")
          ret << param.value
        end

        index = index +1
      end

      return ret
    end
    private :params_conversion
    
    def raw_call(nparam = nil)
      "#{@name}(#{params_conversion(nparam)})"
    end
    private :raw_call
    
    def bind_call(nparam = nil)
      case @return
      when nil
        raise "nil return value is not supported for non-constructors."
      when "void"
        return "#{raw_call(nparam)}; return Qnil;\n"
      else
        return "return cxx2ruby((#{@return})#{raw_call(nparam)});\n"
      end
    end
    private :bind_call

    def stub
      return bind_call unless @variable
      calls = ""

      for n in arguments_range
        calls << "  case #{n}: #{bind_call(n)}"
      end

      return Templates["VariableFunctionCall"].gsub("!calls!", calls)
    end

  end
end
