TESTUNIT=cppclass.rb
SOURCES=cppclass.cc cppclass.hh
GENERATED=cppclass_rb.cc cppclass_rb.hh

test: cppclass_base_generation

cppclass_base_generation: $(GENERATED)


cppclass_rb.hh: cppclass_rb.cc
cppclass_rb.cc: $(SOURCES) $(TESTUNIT)
	ruby -I ../.. -I ../../rust $(TESTUNIT)

clean:
	-rm $(GENERATED)
