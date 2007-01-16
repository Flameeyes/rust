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

require 'rust'
require 'test/unit'
require 'pathname'

module Rust::Test

class Languages < Test::Unit::TestCase
  def test_langcxx
    begin
      Rust::Bindings::create_bindings Rust::Bindings::LangCxx, "languages_rb"
    rescue ArgumentError
      assert false, "C++ Language support not working."
    rescue LocalJumpError
    end
  end

#  def test_langc
#    begin
#      Rust::Bindings::create_bindings Rust::Bindings::LangC, "languages_rb"
#    rescue ArgumentError
#      assert false, "C Language support not working."
#    rescue LocalJumpError
#    end
#  end

  def test_fortran
    begin
      Rust::Bindings::create_bindings "fortran", "languages_rb"
    rescue ArgumentError
    rescue LocalJumpError
      assert false, "Fortran not recognised as non-supported."
    end
  end
end

end
