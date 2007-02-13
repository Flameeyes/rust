TESTUNIT=cppclass.rb
SOURCES=cppclass.cc cppclass.hh
GENERATED=cppclass_rb.cc cppclass_rb.hh
RUST_SOURCES=$(wildcard ../../rust/*.rb)
RUBY_INCLUDEDIR=`ruby -e 'require "rbconfig"; print Config::CONFIG["archdir"];'`

test: cppclass_base_generation

cppclass_base_generation: $(GENERATED)


cppclass_rb.hh: cppclass_rb.cc
cppclass_rb.cc: $(SOURCES) $(TESTUNIT) $(RUST_SOURCES)
	ruby -I ../.. -I ../../rust $(TESTUNIT)

cppclass.so: cppclass.cc cppclass_rb.cc
	$(CC) -shared -fPIC -I${RUBY_INCLUDEDIR} -I../../include $^ -o $@

clean:
	-rm -f $(GENERATED)
