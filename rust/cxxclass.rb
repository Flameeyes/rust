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
  class CxxClass
    def initialize(name, namespace, parent = nil)
      @name = name
      @ns = namespace
      @parent = parent

      @children = Array.new
    end

   def varname
      "#{@ns.name.gsub("::", "_")}_#{@name}"
   end

   def ptrmap
     @parent ? @parent.ptrmap : "#{@ns.name.gsub("::", "_")}_#{@name}_ptrMap"
   end

   def function_free
      @parent ? @parent.function_free : "#{varname}_free"
   end

   def parentvar
      @parent ? "c#{@parent.varname}" : "rb_cObject"
   end

   def test_children
      return unless @children

      ret = ""

      @children.each { |klass|
         ret << %@
if ( dynamic_cast< #{klass.ns.cxxname}::#{klass.name}* >(instance) != NULL )
{
   klass = c#{klass.varname};
   #{klass.test_children}
}
@
      }

      ret
   end


    def declaration
      CxxClassDeclarations.
        gsub("!class_varname!", varname).
        gsub("!cxx_class_name!", "#{@ns.cxxname}::#{@name}").
        gsub("!class_ptrmap!", ptrmap)
    end
    
    def definition
      CxxClassDefinitions.
        gsub("!class_varname!", varname).
        gsub("!cxx_class_name!", "#{@ns.cxxname}::#{@name}").
        gsub("!class_ptrmap!", ptrmap).
        gsub("!test_children!", test_children)
    end
    
    def initialization
    end
  end
end
