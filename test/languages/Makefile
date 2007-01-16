TESTUNIT=languages.rb
RUST_SOURCES=$(wildcard ../../rust/*.rb)

test: languages

languages: $(TESTUNIT) $(RUST_SOURCES)
	ruby -I ../.. -I ../../rust $(TESTUNIT)
