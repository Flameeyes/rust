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

require "rust/cxxclass"
require "rust/cwrapper"

module Rust

  class Namespace
    attr_reader :name, :cxxname, :varname

    def initialize(name, cxxname)
      @name = name
      @cxxname = cxxname
      @varname = "#{@name.gsub("::", "_")}"

      @classes = Array.new
      @functions = [] 
    end

    def add_cxx_class(name, parent = nil)
      klass = CxxClass.new(name, self, parent)

      yield klass

      @classes << klass
      return klass
    end

    def add_class_wrapper(name, type)
      klass = ClassWrapper.new(name, type, self)
      
      yield klass

      @classes << klass
      return klass
    end

    def add_function(name, return_value = "void", bindname = name)
      function = Function.new({ :name => name,
                                :bindname => bindname,
                                :return => return_value,
                                :parent => self
                              })

      begin
        yield function
      rescue LocalJumpError
        # Ignore this, we can easily have methods without parameters
        # or other extra informations.
      end

      @functions << function

      return function
    end

    def declaration
      ret = Templates["ModuleDeclarations"] +
        @classes.collect { |klass| klass.declaration }.join("\n") +
        @functions.collect { |funct| funct.declaration }.join("\n")

      ret.
        gsub("!module_name!", @name).
        gsub("!namespace_varname!", varname)
    end
    
    def definition
      ret = Templates["ModuleDefinitions"] +
        @classes.collect { |klass| klass.definition }.join("\n") +
        @functions.collect { |funct| funct.definition }.join("\n")

      ret.
        gsub("!module_name!", @name).
        gsub("!namespace_varname!", varname)
    end
    
    def initialization
      unless @name.include?("::")
        ret = "r#{varname} = rb_define_module(\"#{@name}\");\n"
      else
        ret = "r#{varname} = rb_define_module_under(m#{@name.split("::")[0..-2].join("_")}, \"#{@name.split("::").last}\");\n"
      end

      ret << @classes.collect { |klass| klass.initialization }.join("\n")
      ret << @functions.collect { |funct| funct.initialization }.join("\n")
      
      ret.
        gsub("!module_name!", @name).
        gsub("!namespace_varname!", varname)
    end
  end

end
