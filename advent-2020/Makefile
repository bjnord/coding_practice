DIRS = day-01 day-02 day-03 day-04 day-05 day-06 day-07 day-08 day-09 day-10 \
	day-11 day-12 day-13 day-14 day-15 day-16 day-17 day-18 day-19 day-20 \
	day-21 day-22 day-23 day-24 day-25

.PHONY: debug release test clippy doc clean

debug:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d debug || break; \
	done

release:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d release || break; \
	done

test:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d test || break; \
	done

clippy:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d clippy || break; \
	done

doc:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d doc || break; \
	done

clean:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d clean || break; \
	done
