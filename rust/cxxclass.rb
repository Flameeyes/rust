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

require 'rust/cxxmethod'

module Rust
  class CxxClass
    attr_reader :name
    attr_reader :varname, :ptrmap, :function_free, :parent_varname

    # Rust::Namespace object for the class, used to get the proper C++
    # name.
    attr_reader :namespace

    # This function initializes the CxxClass instance by setting the
    # values to the attributes defining its parent, namespace, name
    # and a few other needed information.
    #
    # When a C++ Class is bound that is a child of another class, it
    # shares its highest anchestor's pointer map (as that is the
    # more general pointer type it can be referred to with), and
    # function to call when free()'ing.
    #
    # Don't call this function directly, use Namespace.add_cxx_class
    #
    # *FIXME*: multiple inheritance can make Rust bail out, badly.
    def initialize(name, namespace, parent = nil) # :notnew:
      @name = name
      @namespace = namespace
      @parent = parent

      @children = Array.new
      @methods = Array.new

      @varname = "#{@namespace.name.gsub("::", "_")}_#{@name}"
      if @parent
        @ptrmap = @parent.ptrmap
        @function_free = @parent.function_free
        @parent_varname = "c#{@parent.varname}"
      else
        @ptrmap = "#{@namespace.name.gsub("::", "_")}_#{@name}_ptrMap"
        @function_free = "#{varname}_free"
        @parent_varname = "rb_cObject"
      end
    end

    # Adds a new constructor for the class.
    # This function creates a new constructor method for the C++
    # class to bind, and yields it so that parameters can be added
    # afterward.
    def add_constructor
      constructor = Constructor.new(self)

      begin
        yield constructor
      rescue LocalJumpError
        # Ignore this, we can easily have methods without parameters
        # or other extra informations.
      end

      @methods << constructor

      return constructor
    end

    def add_method(name, return_value = "void", bindname = name)
      method = Method.new({ :name => name,
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

      @methods << method

      return method
    end

    # This function is used during ruby to C/C++ conversion of the
    # types, and test for the deepest class the pointer is valid for.
    def test_children
      return unless @children
      
      ret = ""
      
      @children.each do |klass|
        ret << %@
     if ( dynamic_cast< #{klass.namespace.cxxname}::#{klass.name}* >(instance) != NULL )
     {
       klass = c#{klass.varname};
       #{klass.test_children}
     }
     @
      end

      return ret
    end

    def declaration
      ret = (Templates["CxxClassDeclarations"] + (@parent ? "" : Templates["CxxStandaloneClassDeclarations"] )).
        gsub("!class_varname!", varname).
        gsub("!cxx_class_name!", "#{@namespace.cxxname}::#{@name}").
        gsub("!class_ptrmap!", ptrmap)

      @methods.each do |method|
        ret << "#{method.prototype};"
      end

      return ret
    end
    
    def definition
      ret = (Templates["CxxClassDefinitions"] + (@parent ? "" : Templates["CxxStandaloneClassDefinitions"] )).
        gsub("!class_varname!", varname).
        gsub("!cxx_class_name!", "#{@namespace.cxxname}::#{@name}").
        gsub("!class_ptrmap!", ptrmap).
        gsub("!test_children!", test_children).
        gsub("!class_free_function!", @function_free)

      @methods.each do |method|
        ret << method.definition.
          gsub("!class_ptrmap!", ptrmap).
          gsub("!class_varname!", varname).
          gsub("!cxx_class_name!", "#{@namespace.cxxname}::#{@name}")
      end

      return ret
    end
    
    def initialization
      ret = Templates["CxxClassInitialize"].
        gsub("!class_varname!", varname).
        gsub("!cxx_class_basename!", @name.split("::").last).
        gsub("!parent_varname!", @parent_varname).
        gsub("!namespace_varname!", @namespace.varname)

      @methods.each do |method|
        ret << method.initialization
      end

      return ret
    end
  end
end
