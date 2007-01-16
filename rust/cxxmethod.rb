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
  class CxxClass

    # This class is used to represent a method for a C++ class bound
    # in a Ruby extension. Through an object of this class you can add
    # parameters and more to the method.
    class Method < Function
      
      # Initialisation function, calls Function.initialize and sets
      # the important parameters that differs from a generic function
      def initialize(params) # :notnew:
        super

        @klass = params[:klass]
        @varname = "f#{@klass.namespace.name.gsub("::","_")}_#{@klass.name}_#{@name}"
      end
    end
  end
end
