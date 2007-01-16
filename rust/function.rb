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

require 'set'

module Rust
  # This class represent an abstracted bound function; it is not
  # supposed to be used directly, instead its subclass should be used,
  # like CxxClass::Method.
  class Function
    # Class representing a function or method parameter
    class Parameter

      attr_reader :type, :name, :optiona, :default

      def initialize(type, name, optional, default) #:notnew:
        @type = type
        @name = name
        @optional = optional
        @default = default
      end

      # Returns the string of the parameter conversion from ruby to
      # C++.
      #
      # The index parameter 
      def conversion(index = nil)
        paramname = index ? "argv[#{index}]" : @name

        "ruby2#{@type.sub("*", "Ptr").gsub("::", "_")}(#{paramname}),"
      end
    end

    attr_reader :varname

    # Initialisation function, sets the important parameters from the
    # params hash provided, and the derived information that are needed.
    def initialize(params) # :notnew:
      @return = params[:return]
      @name = params[:name]
      @bindname = params[:bindname]

      @varname = "f#{@name}"

      @aliases = Set.new
      @parameters = Array.new
      @variable = false # Variable arguments function
    end

    # Adds an alias for the function.
    # The same C++ function can be bound with more than one name,
    # as CamelCase names in the methods are bound also  with
    # ruby_style names, so that the users can choose what to use.
    def add_alias(name)
      @aliases << name
    end

    # Adds a new parameter to the function
    def add_parameter(name, type, optional = false, default = nil)
      param = Parameter.new(name, type, optional, default)
      @parameters << param

      @variable = true if optional or default != nil

      return param
    end
  end
end
