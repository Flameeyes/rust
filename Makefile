all:
	@echo "Just run 'make check' if you want to run test units"
	@echo "or 'make doc' if you want to build the documentation"

check:
	for test in test/test-*.rb; do \
		unit=$${test#*/}; \
		ruby -C test $${unit} || exit 0; \
	done

doc:
	rdoc -o rust-doc -t 'Rust Documentation' rust
