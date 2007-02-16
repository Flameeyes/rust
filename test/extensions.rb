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
require 'rbconfig'

$: << ".."

class RustTest < Test::Unit::TestCase
  def setup
    cleanup

    extname, language = name[5..-1].split('(')[0].split("_")
    puts "Building extension #{extname} (#{language})"

    case language
    when 'c' then [ 'c', 'h', 'rb' ]
    when 'cc' then [ 'cc', 'hh', 'rb' ]
    when 'rb' then [ 'rb' ]
    end.each do |ext|
      assert( File.exist?("#{extname}.#{ext}"),
              "Missing prerequisite #{extname}.#{ext} source file" )
    end

    load "./#{extname}.rb"

    assert( (File.exists?("#{extname}_rb.cc") && File.exist?("#{extname}_rb.hh")),
            "The extension's source files weren't generated.")

    cxx = ENV['CXX'] ? ENV['CXX'] : 'c++'
    cc =  ENV['CC'] ? ENV['CC'] : 'cc'
    cxxflags = "#{ENV['CXXFLAGS']} -I#{Config::CONFIG["archdir"]} -I../include -DDEBUG -fPIC"
    cflags = "#{ENV['CFLAGS']} -DDEBUG -fPIC"
    ldflags = "#{ENV['LDFLAGS']} -Wl,-z,defs -shared"

    cmdlines = []
    case language
    when 'cc'
      sourcefile = "#{extname}.cc"
    when 'c'
      sourcefile = "#{extname}.o"
      cmdlines << "#{cc} #{cflags} #{extname}.c -c -o #{extname}.o"
    end

    cmdlines << "#{cxx} #{cxxflags} #{ldflags} #{sourcefile} #{extname}_rb.cc -o #{extname}_rb.so -lruby"

    cmdlines.each do |cmd|
      puts cmd
      ret = system cmd
      assert ret, "Building of extension #{extname} failed."
    end

    require "./#{extname}_rb.so"
  end

  def cleanup
    extname, language = name[5..-1].split('(')[0].split("_")

    [ "c", "cc", "h", "hh", "so" ].each do |extension|
      File.unlink("#{extname}_rb.#{extension}") if File.exists?("#{extname}_rb.#{extension}")
    end

    File.unlink("#{extname}.o") if File.exists?("#{extname}.o")
  end

  def test_cppclass_cc
    @instance = RustTestCppClass::TestClass.new

    @instance.action1 1234
    assert @instance.integerValue == 1234, "The integer value does not correspond"

    @instance.action2 "a test"
    assert @instance.stringValue == "a test", "The string value does not correspond"

    assert( RustTestCppClass::TestClass.instance_methods.include?("integer_value"),
            "The converted CamelCase to ruby_convention is missing." )
    assert( RustTestCppClass::TestClass.instance_method("integer_value") == RustTestCppClass::TestClass.instance_method("integerValue"),
            "The converted CamelCase to ruby_conversion is not an alias of the original method" )

    cleanup
  end

  def test_cwrapper_c
    assert(RustTestCWrapper::TestConstant == 1985, "The test constant is not set properly.")
    assert(RustTestCWrapper::get_default_integer == 1985, "The module function is not set properly.")

    @instance = RustTestCWrapper::TestClass.new

    assert(@instance.get_integer == RustTestCWrapper::get_default_integer, "The get_integer function does not work properly")

    @instance.set_integer(1987)
    assert(@instance.get_integer == 1987, "The set_integer function does not work properly")

    assert(@instance.get_string == "", "The get_string function does not work properly")

    assert(@instance.set_string("ciao") == true, "The set_string function does not return true for valid values")
    assert(@instance.get_string == "ciao", "The set_string function does not work properly")


    assert(@instance.set_string("foobar" * 70) == false, "The set_string function does not return true for invalid values")
    assert(@instance.get_string == "ciao", "The set_string function does not ignore invalid values")

    cleanup
  end

  def test_constants_rb
    assert(RustTestConstants::DummyClass::ClassConstant == 123,
           "The class constant is not set properly.")
    assert(RustTestConstants::ModuleConstant == "foobar",
           "The module constant is not set properly.")
    
    cleanup
  end
end
