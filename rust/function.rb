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

module Rust
  # This class represent an abstracted bound function; it is not
  # supposed to be used directly, instead its subclass should be used,
  # like CxxClass::Method.
  class Function
    # Class representing a function or method parameter
    class Parameter

      attr_reader :type, :name, :optional, :default

      def initialize(type, name, optional, default) #:notnew:
        @type = type
        @name = name
        @optional = optional
        @default = default
      end

      # Returns the string of the parameter conversion from ruby to
      # C++.
      #
      # The index parameter 
      def conversion(index = nil)
        paramname = index ? "argv[#{index}]" : @name

        "ruby2#{@type.sub("*", "Ptr").gsub("::", "_").gsub(' ', '')}(#{paramname}),"
      end
    end

    attr_reader :varname

    # Initialisation function, sets the important parameters from the
    # params hash provided, and the derived information that are needed.
    def initialize(params) # :notnew:
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

      @definition_template = Templates["FunctionDefinition"]
      @prototype_template = "VALUE !function_varname! ( VALUE self !function_parameters! )"
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
    def add_parameter(name, type, optional = false, default = nil)
      param = Parameter.new(name, type, optional, default)
      @parameters << param

      if optional or default != nil
        @variable = true 
        @prototype_template = "VALUE !function_varname! ( int argc, VALUE *argv, VALUE self )"
      end

      return param
    end

    # Set different, non-default templates for functions, that can be used
    # when many functions of the bound C/C++ library contains functions
    # that require to be handled in a particular way.
    def set_custom(prototype, definition)
      @definition_template = definition
      @prototype_template = prototype
    end

    def params_conversion(nparms = nil, params = nil)
      return if @parameters.empty?
      vararg = nparms != nil
      nparms = @parameters.size unless nparms
      
      ret = ""
      @parameters.slice(0, nparms).each_index { |p|
        ret << @parameters[p].conversion( vararg ? p : nil )
      }
      ret << "#{params[0]}," if params
      
      ret.chomp!(",")
    end
    private :params_conversion
    
    def definition
      @definition_template.
        gsub("!function_prototype!", prototype).
        gsub("!function_call!", stub).
        gsub("!function_varname!", varname).
        gsub("!function_cname!", @name)
    end

    def prototype
      @prototype_template.
        gsub("!function_varname!", varname).
        gsub("!function_parameters!", @parameters.collect { |p| ", VALUE #{p.name}" }.join)
    end
    
    def raw_call(param = nil, params = nil)
      "#{@name}(#{params_conversion(param, params)})"
    end
    private :raw_call
    
    def bind_call(param = nil, params = nil)
      case @return
      when nil
        raise "nil return value is not supported for non-constructors."
      when "void"
        return "#{raw_call(param, params)}; return Qnil;\n"
      else
        return "return cxx2ruby((#{@return})#{raw_call(param, params)});\n"
      end
    end
    private :bind_call

    def stub
      return bind_call unless @variable
      calls = ""

      for n in 0..(@parameters.size-1)
        calls << "  case #{n}: #{bind_call(n)}" if @parameters[n].optional
        calls << "  case #{n}: #{bind_call(n, [@parameters[n].default])}" if
          @parameters[n].default
      end

      calls << "  case #{@parameters.size}: #{bind_call(@parameters.size)}"

      return Templates["VariableFunctionCall"].gsub("!calls!", calls)
    end
    
    def initialization
      paramcount = 
        case
          # when @custom then @custom_paramcount
          # when @template then @template_paramcount
        when @variable then -1
        else @parameters.size
        end

      ret = Templates["FunctionInitBinding"].
        gsub("!parent_varname!", @parent.varname).
        gsub("!function_bindname!", @bindname).
        gsub("!function_varname!", @varname).
        gsub("!function_paramcount!", paramcount.to_s)

      @aliases.each do |alii|
        ret << Templates["FunctionInitAlias"].
          gsub("!parent_varname!", @parent.varname).
          gsub("!function_alias!", alii).
          gsub("!function_bindname!", @bindname)
      end

      return ret
    end

  end
end
