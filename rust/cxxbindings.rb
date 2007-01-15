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

require 'rust/namespace'

module Rust
  class CxxBindings < Bindings
    # Adds an include header with the specified name.
    # This function adds to the list of header files to include the
    # one with the specified name.
    #
    # If the scope paramether is set to Bindings.HeaderLocal, the name of
    # the header file will be enclosed in double quotes ("") while
    # including it, while it will be included it in angle quotes if
    # the parameter is set to Bindings.HeaderGlobal (the default).
    def include_header(name, scope = Bindings::Global)
      name = 
        case scope
        when HeaderLocal then "\"#{name}\""
        when HeaderGlobal then "<#{name}>"
        else
          raise ArgumentError, "#{scope} not a valid value for scope parameter."
        end

      @cxx_includes << "\n#include #{name}"
    end
  end
end
