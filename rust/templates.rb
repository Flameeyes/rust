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

  CxxClassDeclarations = 
%@
extern VALUE c!class_varname!;
VALUE cxx2ruby(!cxx_class_name!* instance);
!cxx_class_name!* ruby2!class_varname!Ptr(VALUE rval);
@

  CxxClassDefinitions =
%@
VALUE c!class_varname!;

!cxx_class_name!* ruby2!class_varname!Ptr(VALUE rval) {
   !cxx_class_name!* ptr;
   Data_Get_Struct(rval, !cxx_class_name!, ptr);

   if ( ptr ) return dynamic_cast< !cxx_class_name!* >(ptr);

   T!class_ptrmap!::iterator it = !class_ptrmap!.find(rval);

   if ( it == !class_ptrmap!.end() ) {
      rb_raise(rb_eRuntimeError, "Unable to find !cxx_class_name! instance for value %x (type %d)\\n", rval, TYPE(rval));
      return NULL;
   }

   return dynamic_cast< !cxx_class_name!* >((*it).second);
}

VALUE cxx2ruby(!cxx_class_name!* instance) {
  if ( instance == NULL ) return Qnil;

  T!class_ptrmap!::iterator it, eend = !class_ptrmap!.end();

  for(it = !class_ptrmap!.begin(); it != eend; it++)
     if ( (*it).second == (!cxx_class_name!*)instance ) break;

   if ( it != !class_ptrmap!.end() )
      return (*it).first;
   else {
      VALUE klass = c!class_varname!;

!test_children!

      VALUE rval = Data_Wrap_Struct(klass, 0, 0, (void*)instance);
      !class_ptrmap![rval] = instance;
      // fprintf(stderr, "Wrapping instance %p in value %x (type %d)\\n", instance, rval, TYPE(rval));
      return rval;
   }
}

static VALUE !class_varname!_alloc(VALUE self) {
   return Data_Wrap_Struct(self, 0, !class_free_function!, 0);
}
@

  CxxStandaloneClassDeclarations =
%@
typedef std::map<VALUE, !cxx_class_name!*> T!class_ptrmap!;
extern T!class_ptrmap! !class_ptrmap!;
static void !class_varname!_free(void *p);
@

  CxxStandaloneClassDefinitions = 
%@
T!class_ptrmap! !class_ptrmap!;

static void !class_varname!_free(void *p) {
  T!class_ptrmap!::iterator it, eend = !class_ptrmap!.end();
  for(it = !class_ptrmap!.begin(); it != eend; it++)
     if ( (*it).second == (!cxx_class_name!*)p ) {
        !class_ptrmap!.erase(it); break;
     }
  delete (!cxx_class_name!*)p;
}
@

end
