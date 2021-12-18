BIN = ./snailfish
FILES = mix.exs test/test_helper.exs \
	lib/snailfish.ex test/snailfish_test.exs \
	lib/snailfish/smath.ex test/snailfish/smath_test.exs \
	lib/snailfish/parser.ex test/snailfish/parser_test.exs
VERBOSE = 0
TIMES = 0
ifneq ($(TIMES), 0)
TIMESARG = --times
ifneq ($(VERBOSE), 0)
TIMESARG += --verbose
endif
endif

.PHONY: run test cprof doc console clean

run: $(BIN)
	$(BIN) $(TIMESARG) input/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

# NB this is supposed to work for `eprof` and `fprof` too
#    but the latter crashes for me
cprof:
	mix profile.cprof -e 'Snailfish.part2("input/input.txt")' >log/cprof.out

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log log/cprof.out

$(BIN): $(FILES)
	mix escript.build
