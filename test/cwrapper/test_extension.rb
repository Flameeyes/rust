# Copyright (c) 2007 Diego Pettenò <flameeyes@gmail.com>
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

class CWrapperExtension < Test::Unit::TestCase
  def setup
    require 'cwrapper_rb'
  end

  def test_instance
    @instance = RustTest::TestClass.new
  end

  def test_module_constant
    assert (RustTest::TestConstant == 1985, "The test constant is not set properly.")
  end

  def test_module_function
    assert (RustTest::get_default_integer, "The module function is not set properly.")
  end

  def test_get_integer
    @instance = RustTest::TestClass.new

    assert (@instance.get_integer == RustTest::get_default_integer, "The get_integer function does not work properly")
  end

  def test_set_integer
    @instance = RustTest::TestClass.new

    @instance.set_integer(1987)

    assert (@instance.get_integer == 1987, "The set_integer function does not work properly")
  end

  def test_get_string
    @instance = RustTest::TestClass.new

    assert (@instance.get_string == "", "The get_string function does not work properly")
  end

  def test_set_string_valid
    @instance = RustTest::TestClass.new

    assert (@instance.set_string("ciao") == true, "The set_string function does not return true for valid values")

    assert (@instance.get_string == "ciao", "The set_string function does not work properly")
  end

  def test_set_string_invalid
    @instance = RustTest::TestClass.new

    assert (@instance.set_string("ciao" * 70) == false, "The set_string function does not return true for invalid values")

    assert (@instance.get_string == "", "The set_string function does not ignore invalid values")
  end

end

