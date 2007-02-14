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

require 'rust/function'

module Rust
  class Class
    attr_reader :name, :cname
    attr_reader :varname, :ptrmap, :function_free, :parent_varname

    # Rust::Namespace object for the class, used to get the proper C++
    # name.
    attr_reader :namespace

    # This function initializes the Class instance by setting the
    # values to the attributes defining its namespace, name
    # and a few other needed information.
    #
    # Don't call this function directly, use Namespace.add_cxx_class
    def initialize(name, namespace) # :notnew:
      @name = name
      @namespace = namespace

      @methods = []

      @varname = "#{@namespace.name.gsub("::", "_")}_#{@name}"
      @parent_varname = "rb_cObject"
      
      @ptrmap = "#{@namespace.name.gsub("::", "_")}_#{@name}_ptrMap"
      @function_free = "#{varname}_free"

      @cname = @namespace.cxxname ? "#{@namespace.cxxname}::#{@name}" : @name

      @declaration_template = Templates["ClassDeclarations"]
      @definition_template = Templates["ClassDefinitions"]
      @initialization_template = Templates["ClassInitialize"]
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

      @methods << constructor

      return constructor
    end

    def declaration
      ret = @declaration_template
      @methods.each do |method|
        ret << "#{method.prototype};"
      end

      ret.
        gsub("!class_varname!", varname).
        gsub("!c_class_name!", cname).
        gsub("!class_ptrmap!", ptrmap)
    end
    
    def definition
      ret = @definition_template
      @methods.each do |method|
        ret << method.definition
      end

      ret.
        gsub("!class_varname!", varname).
        gsub("!c_class_name!", cname).
        gsub("!class_ptrmap!", ptrmap).
        gsub("!test_children!", test_children).
        gsub("!class_free_function!", @function_free)
    end
    
    def initialization
      ret = @initialization_template
      @methods.each do |method|
        ret << method.initialization
      end

      ret.
        gsub("!class_varname!", varname).
        gsub("!c_class_basename!", @name.split("::").last).
        gsub("!parent_varname!", @parent_varname)
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

      def bind_call(param = nil, params = nil)
        "#{raw_call(param, params)};\n"
      end
    end

  end
end
