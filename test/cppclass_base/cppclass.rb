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

class CppClassBase < Test::Unit::TestCase
  def setup
    Rust::Bindings::create_bindings Rust::Bindings::LangCxx, "cppclass_rb" do |b|
      b.include_header 'cppclass.hh', Rust::Bindings::HeaderLocal

      b.add_namespace "RustTest", "" do |ns|
        ns.add_cxx_class "TestClass" do |klass|
          klass.add_constructor do |method|
          end

          klass.add_method "action1" do |method|
            method.add_parameter "uint32_t", "val"
          end

          klass.add_method "action2" do |method|
            method.add_parameter "char *", "string"
          end

          klass.add_method "integerValue", "uint32_t" do |method|
          end

          klass.add_method "stringValue", "std::string" do |method|
          end
        end
      end
    end
  end

  def test_presence
    assert Pathname.new("cppclass_rb.cc").exist?, "The bindings unit wasn't created"
    assert Pathname.new("cppclass_rb.hh").exist?, "The bindings header wasn't created"
  end
end

end
