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

require 'test/unit'
require 'rust'

module Rust::Test

class Extension < Test::Unit::TestCase
  def setup
    require 'cppclass_rb'
  end

  def test_01constructor
    @instance = RustTest::TestClass.new
  end

  def test_02integers
    foo.action1 1234
    assert foo.integerValue == 1234, "The integer value does not correspond"
  end

  def test_03strings
    foo.action2 "a test"
    assert foo.stringValue == "a test", "The string value does not correspond"
  end

  def test_04camel
    assert foo.integer_value == 1234, "Camel case to ruby conversion does not work"
    assert foo.string_value == "a test", "Camel case to ruby conversion does not work"
  end
end

end

