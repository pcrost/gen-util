SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

test: $(patsubst %.vhdx,%.vhdl,$(wildcard tests/*.vhdx))

$(SELF_DIR)/lib/x-filter.so: $(SELF_DIR)/tools/o-creat.c $(SELF_DIR)/tools/x-filter.c
	gcc -shared -fPIC -ldl -fpic $^ -o $@

%.v: %.v.c $(SELF_DIR)/lib/x-filter.so
	$(shell PATH=$(PATH):$(SELF_DIR)/bin LD_PRELOAD=$(SELF_DIR)/lib/x-filter.so gcc -E -nostdinc -undef -P -w $< -I$(SELF_DIR) $(GCCFLAGS) -o $@)
	cp $@ $@.debug

%.v.c: %.vx
	cp $< $@
