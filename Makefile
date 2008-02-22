PACKAGE = rust

ifeq "$(VERSION)" ""
VERSION = $(shell date +"%Y-%m-%d_%H-%M")
endif

all:
	@echo "Just run 'make check' if you want to run test units"
	@echo "or 'make doc' if you want to build the documentation"

dist: $(PACKAGE)-$(VERSION).tar.bz2

check:
	for test in test/test-*.rb; do \
		unit=$${test#*/}; \
		ruby -C test $${unit} || exit 0; \
	done

doc:
	rdoc -o rust-doc -t 'Rust Documentation' rust

$(PACKAGE)-$(VERSION).tar.bz2: $(shell git ls-files)
	git archive --format=tar --prefix=$(PACKAGE)-$(VERSION)/ HEAD | bzip2 > $@

.PHONY: all check doc dist
