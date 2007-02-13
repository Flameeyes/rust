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
        params[:parent] = params[:klass]
        super

        @varname =
        "f#{@parent.namespace.name.gsub("::","_")}_#{@parent.name}_#{@name}"

        @definition_template = Templates["CxxMethodStub"]
      end

      def raw_call(param = nil)
        "tmp->#{super(param)}"
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

        @definition_template = Templates["CxxConstructorStub"]
      end

      def raw_call(param = nul)
        "tmp = new #{super(param)}"
      end

      def bind_call(param = nil, params = nil)
        "#{raw_call(param)};\n"
      end
    end
  end
end
