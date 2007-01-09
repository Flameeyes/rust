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
    def extension_unit
      "cc"
    end
    def extension_header
      "hh"
    end

    def initialize(name)
      super(name)

      @namespaces = Array.new
    end

    def add_namespace(name, cxxname = nil)
      cxxname = name if cxxname == nil 

      ns = Namespace.new(name, cxxname)

      yield ns

      @namespaces << ns
    end

    def unit
      @namespaces.collect { |ns| ns.unit }.join("\n")
    end

    def header
      @namespaces.collect { |ns| ns.header }.join("\n")
    end

    def init
      @namespaces.collect { |ns| ns.init }.join("\n")
    end

  end

end
