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
  # Base class to use to create bindings for ruby.
  # You shouldn't instantiate this manually, but rather use the
  # create_bindings function.
  class Bindings
    C = "c"     # :nodoc:
    CXX = "cxx" # :nodoc:

    def initialize(name) # :notnew:
      @name = name

      @modules = Array.new
      @cxx_includes = ""
      @c_includes = ""
    end

    # This function is called when creating a set of bindings for
    # Ruby; the first parameter is one of Rust::Bindings::C or
    # Rust::Bindings::CXX constants, and decides whether the bindings
    # are for a C or C++ library. Although Rust still generates C++
    # code for the extension, when binding a C++ library, the classes
    # are mapped 1:1 from the C++ interface, while when binding a C
    # library you need to create "false" classes that wraps around the
    # C interface.
    def Bindings.create_bindings(type, name)
      bindings = 
        case type
        when Bindings::CXX
          bindings = CxxBindings.new(name)
#        when Bindings::C
#          bindings = CBindings.new(name)
        end

      yield bindings

      header = File.new("#{name}.hh", "w")
      unit = File.new("#{name}.cc", "w")
      
      header.puts bindings.header
      unit.puts bindings.unit
    end

    # Binds a new Namespace to a Ruby module; the name parameter is
    # used as the name of the module, while the cxxname one (if not
    # null) is used to indicate the actual C++ namespace to use; when
    # binding a C library, you should rather use the add_module
    # function, although that's just a partial wrapper around this one.
    def add_namespace(name, cxxname = nil)
      cxxname = name if cxxname == nil 

      ns = Namespace.new(name, cxxname)

      yield ns

      @modules << ns
    end

    # Create a new Ruby module with the given name; this is used when
    # binding C libraries, as they don't use namespace, so you have to
    # create the modules from scratch.
    def add_module(name)
      add_namespace(name, "")
    end

    # Returns the content of the header for the bindings, recursively
    # calling the proper functions to get the declarations for the
    # modules bound and so on.
    #
    # This should *never* be used directly
    def header
      BindingsHeader.
        gsub("!bindings_name!", @name).
        gsub("!modules_declaration!", @modules.collect { |ns| ns.declaration }.join("\n")).
        gsub("!cxx_includes!", @cxx_includes).
        gsub("!c_includes!", @c_includes)
    end

    # Returns the content of the unit for the bindings, recursively
    # calling the proper functions to get the definitions and the
    # initialisation function for the modules bound and so on.
    #
    # This should *never* be used directly
    def unit
      BindingsUnit.
        gsub("!bindings_name!", @name).
        gsub("!modules_initialization!", @modules.collect { |ns| ns.initialization }.join("\n")).
        gsub("!modules_definition!", @modules.collect { |ns| ns.definition }.join("\n"))
    end
  end

end

require 'rust/cxxbindings'

