TESTDIRS=cppclass_base languages cwrapper

all: test

test:
	for subdir in $(TESTDIRS); do \
		make -C $$subdir test || exit 1; \
	done

clean:
	-for subdir in $(TESTDIRS); do \
		make -k -C $$subdir clean || exit 0; \
	done
