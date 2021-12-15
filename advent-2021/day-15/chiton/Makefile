BIN = ./chiton
FILES = mix.exs test/test_helper.exs \
	lib/chiton.ex test/chiton_test.exs \
	lib/chiton/cave.ex test/chiton/cave_test.exs
VERBOSE = 0
TIMES = 0
ifneq ($(TIMES), 0)
TIMESARG = --times
ifneq ($(VERBOSE), 0)
TIMESARG += --verbose
endif
endif

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN) $(TIMESARG) input/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log

$(BIN): $(FILES)
	mix escript.build
