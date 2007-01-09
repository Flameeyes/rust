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
  class Bindings
    C = "c"
    CXX = "cxx"

    def initialize(name)
      @name = name

      @modules = Array.new
      @cxx_includes = ""
      @c_includes = ""
    end

    def Bindings.create_bindings(type, name)
      bindings = 
        case type
        when Bindings::CXX
          bindings = CxxBindings.new(name)
#        when Bindings::C
#          bindings = CBindings.new(name)
        end

      yield bindings

      header = File.new("#{name}.#{bindings.extension_header}", "w")
      unit = File.new("#{name}.#{bindings.extension_unit}", "w")
      
      header.puts bindings.header
      unit.puts bindings.unit
    end

    def add_namespace(name, cxxname = nil)
      cxxname = name if cxxname == nil 

      ns = Namespace.new(name, cxxname)

      yield ns

      @modules << ns
    end

    def add_module(name)
      add_namespace(name, nil)
    end

    def header
      BindingsHeader.
        gsub("!bindings_name!", @name).
        gsub("!modules_declaration!", @modules.collect { |ns| ns.declaration }.join("\n")).
        gsub("!cxx_includes!", @cxx_includes).
        gsub("!c_includes!", @c_includes)
    end

    def unit
      BindingsUnit.
        gsub("!bindings_name!", @name).
        gsub("!modules_initialization!", @modules.collect { |ns| ns.initialization }.join("\n")).
        gsub("!modules_definition!", @modules.collect { |ns| ns.definition }.join("\n"))
    end
  end

end

require 'rust/cxxbindings'

