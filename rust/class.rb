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

require 'rust/container'
require 'rust/function'

module Rust
  class Class < Container
    attr_reader :name, :cname
    attr_reader :varname, :varcname, :ptrmap, :function_free, :parent_varname

    # Rust::Namespace object for the class, used to get the proper C++
    # name.
    attr_reader :namespace

    # This function initializes the Class instance by setting the
    # values to the attributes defining its namespace, name
    # and a few other needed information.
    #
    # Don't call this function directly, use Namespace.add_cxx_class
    def initialize(name, namespace) # :notnew:
      super()

      @name = name
      @namespace = namespace

      @varname = "#{@namespace.name.gsub("::", "_")}_#{@name}"
      @parent_varname = "rb_cObject"
      
      @ptrmap = "#{@namespace.name.gsub("::", "_")}_#{@name}_ptrMap"
      @function_free = "#{varname}_free"

      @cname = @namespace.cname ? "#{@namespace.cname}::#{@name}" : @name
      @varcname = @cname.sub("*", "Ptr").gsub("::", "_").gsub(' ', '')

      @declaration_template = Templates["ClassDeclarations"]
      @initialization_template = Templates["ClassInitialize"]

      add_expansion 'class_varname', 'varname'
      add_expansion 'class_varcname', 'varcname'
      add_expansion 'c_class_name', 'cname'
      add_expansion 'c_class_basename', '@name.split("::").last'
      add_expansion 'class_ptrmap', 'ptrmap'
      add_expansion 'class_free_function', '@function_free'
      add_expansion 'parent_varname', '@parent_varname'
    end

    # Adds a new constructor for the class.
    # This function creates a new constructor method for the C/C++
    # class to bind, and yields it so that parameters can be added
    # afterward.
    def add_constructor
      constructor = self.class::Constructor.new(self)

      begin
        yield constructor
      rescue LocalJumpError
        # Ignore this, we can easily have methods without parameters
        # or other extra informations.
      end

      @children << constructor

      return constructor
    end

    # Adds a new method for the class.
    # This function adds a new generic method for the class. In the
    # case of C++ classes, this is an actual method of the bound
    # class, while in case of Class Wrappers, this is just a function
    # that expects to find a static parameter that is the instance
    # pointer itself.
    def add_method(name, return_value = "void", bindname = name)
      method = self.class::Method.new({ :name => name,
                            :bindname => bindname,
                            :return => return_value,
                            :klass => self
                          })

      begin
        yield method
      rescue LocalJumpError
        # Ignore this, we can easily have methods without parameters
        # or other extra informations.
      end

      @children << method

      return method
    end

    # Adds a new variable for the class. It's not an actual variable,
    # as hopefully there aren't global or class public variables in
    # any library.
    # These virtual variables have setter and getter methods, usually
    # called 'var' and 'setVar' in C++ (or 'getVar' and 'setVar'), and
    # are mapped to 'var' and 'var=' in Ruby, so that setting the
    # variable in Ruby will just call the setter method.
    def add_variable(name, type, getter = nil, setter = nil)
      getter = name unless getter
      setter = "set" + name[0..0].capitalize + name[1..-1] unless
        setter

      method_get = add_method getter, type
      method_get.add_alias name

      method_set = add_method setter, "void"
      method_set.add_alias "#{name}="

      begin
        yield method_get, method_set
      rescue LocalJumpError
        # Ignore this, we can easily have methods without parameters
        # or other extra informations.
      end

      method_set.add_parameter type, "value"

      return [method_get, method_set]
    end

    # This class is used to represent a method for a C/C++ class bound
    # in a Ruby extension. Through an object of this class you can add
    # parameters and more to the method.
    class Method < Function
      
      # Initialisation function, calls Function.initialize and sets
      # the important parameters that differs from a generic function
      def initialize(params) # :notnew:
        params[:parent] = params[:klass]
        super

        @varname =
        "f#{@parent.namespace.name.gsub("::","_")}_#{@parent.name}_#{@name}"

        @definition_template = Templates["CxxMethodStub"]
        @initialization_template = Templates["MethodInitBinding"]
      end
    end

    # This class is used to represente the constructor of a C++ class
    # bound in a Ruby extension.
    class Constructor < Function
      
      # Initialisation function, calls Function.initialise, but accepts
      # only a single parameter, the class the constructor belong to.
      def initialize(klass) # :notnew:
        super({
                :parent => klass,
                :bindname => "initialize",
                :name => klass.name
              })

        @definition_template = Templates["ConstructorStub"]
      end

      def bind_call(nparam = nil)
        "#{raw_call(nparam)};\n"
      end
    end

  end
end
