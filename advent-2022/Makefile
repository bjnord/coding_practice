DIRS = shared day-01 day-02 day-03 day-04 day-05 day-06 day-07 day-08 \
       day-09 day-10 day-11 day-12 day-13 day-14 day-15 day-16 day-17 \
       day-18 day-19 day-20 day-21 day-22 day-23 day-24 day-25

.PHONY: main test lint coverage doc distclean

main:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d || break; \
	done

test:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d test || break; \
	done

lint:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d lint || break; \
	done

coverage:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d coverage || break; \
	done

doc:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d doc || break; \
	done

distclean:
	@for d in $(DIRS); do \
		$(MAKE) -C $$d distclean || break; \
	done
