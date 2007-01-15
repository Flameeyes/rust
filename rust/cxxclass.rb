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
    attr_reader :varname, :ptrmap, :function_free, :parentvar

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
      @ns = namespace
      @parent = parent

      @children = Array.new

      @varname = "#{@ns.name.gsub("::", "_")}_#{@name}"
      if @parent
        @ptrmap = @parent.ptrmap
        @function_free = @parent.function_free
        @parentvar = "c#{@parent.varname}"
      else
        @ptrmap = "#{@ns.name.gsub("::", "_")}_#{@name}_ptrMap"
        @function_free = "#{varname}_free"
        @parentvar = "rb_cObject"
      end
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
      (CxxClassDeclarations + (@parent ? "" : CxxStandaloneClassDeclarations )).
        gsub("!class_varname!", varname).
        gsub("!cxx_class_name!", "#{@ns.cxxname}::#{@name}").
        gsub("!class_ptrmap!", ptrmap)
    end
    
    def definition
      (CxxClassDefinitions + (@parent ? "" : CxxStandaloneClassDefinitions )).
        gsub("!class_varname!", varname).
        gsub("!cxx_class_name!", "#{@ns.cxxname}::#{@name}").
        gsub("!class_ptrmap!", ptrmap).
        gsub("!test_children!", test_children)
    end
    
    def initialization
    end
  end
end
