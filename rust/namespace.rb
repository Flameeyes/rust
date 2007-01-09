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

module Rust

  class Namespace
    attr_reader :name, :cxxname

    def initialize(name, cxxname)
      @name = name
      @cxxname = cxxname

      @cxxclasses = Array.new
      @cwrappers = Array.new
    end

    def varname
      "m#{@name.gsub("::", "_")}"
    end

    def declaration
      ModuleDeclarations.
        gsub("!module_name!", @name).
        gsub("!cxx_classes_declarations!", @cxxclasses.collect { |klass| klass.declaration }.join("\n")).
        gsub("!c_class_wrappers_declarations!", @cwrappers.collect { |klass| klass.declaration }.join("\n"))
    end
    
    def definition
      ModuleDefinitions.
        gsub("!module_name!", @name).
        gsub("!cxx_classes_definitions!", @cxxclasses.collect { |klass| klass.definition }.join("\n")).
        gsub("!c_class_wrappers_definitions!", @cwrappers.collect { |klass| klass.definition }.join("\n"))
    end
    
    def initialization
      unless @name.include?("::")
        ret = "#{varname} = rb_define_module(\"#{@name}\");\n"
      else
        ret = "#{varname} = rb_define_module_under(m#{@name.split("::")[0..-2].join("_")}, \"#{@name.split("::").last}\");\n"
      end
      
      #    @classes.each { |cls|
      #      ret << cls.init
      #    }
      
      ret
    end
  end

end
