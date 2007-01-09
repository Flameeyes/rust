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
  BindingsHeader  = 
%@
extern "C" {
  #include <ruby.h>
  !c_includes!
}

!cxx_includes!

/* This is for the ptrMap */
#include <map>

!modules_declaration!

@

  BindingsUnit =
%@

#include <rust_conversions.hh>
#include "!bindings_name!.hh"

!modules_definition!

extern "C" {

#ifdef HAVE_VISIBILITY
void Init_!bindings_name!() __attribute__((visibility("default")));
#endif

void Init_!bindings_name!() {
!modules_initialization!
} /* Init_!bindings_name! */

}

@

  ModuleDeclarations = 
%@
extern VALUE !module_name!;
!cxx_classes_declarations!
!c_class_wrappers_declarations!
@

  ModuleDefinitions = 
%@
VALUE !module_name!;
!cxx_classes_definitions!
!c_class_wrappers_definitions!
@

end
