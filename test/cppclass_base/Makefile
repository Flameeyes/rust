TESTUNIT=cppclass.rb
SOURCES=cppclass.cc cppclass.hh
RUST_SOURCES=$(wildcard ../../rust/*.rb ../../rust/templates/*.rusttpl)
RUBY_INCLUDEDIR=`ruby -e 'require "rbconfig"; print Config::CONFIG["archdir"];'`

test: cppclass.so

cppclass_rb.hh: cppclass_rb.cc
cppclass_rb.cc: $(SOURCES) $(TESTUNIT) $(RUST_SOURCES)
	ruby -I ../.. -I ../../rust $(TESTUNIT)

cppclass.so: cppclass.cc cppclass_rb.cc
	$(CC) -shared -fPIC -I${RUBY_INCLUDEDIR} -I../../include $^ -o $@

clean:
	-rm -f $(GENERATED)
