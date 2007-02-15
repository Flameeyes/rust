TESTUNIT=cwrapper.rb
SOURCES=cwrapper.c cwrapper.h
RUST_SOURCES=$(wildcard ../../rust/*.rb ../../rust/templates/*.rusttpl)
RUBY_INCLUDEDIR=`ruby -e 'require "rbconfig"; print Config::CONFIG["archdir"];'`
test: test_extension

test_extension: test_extension.rb cwrapper_rb.so
	ruby -I ../.. -I ../../rust test_extension.rb

cwrapper_rb.hh: cwrapper_rb.cc
cwrapper_rb.cc: $(SOURCES) $(TESTUNIT) $(RUST_SOURCES)
	ruby -I ../.. -I ../../rust $(TESTUNIT)

cwrapper_rb.so: cwrapper.c cwrapper_rb.cc
	$(CXX) -DDEBUG -Wl,-z,defs -shared -fPIC -I${RUBY_INCLUDEDIR} -I../../include $^ -o $@ -lruby

clean:
	-rm -f cwrapper_rb.hh cwrapper_rb.cc cwrapper_rb.so
