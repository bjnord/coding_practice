BIN = ./beacon
FILES = mix.exs test/test_helper.exs \
	lib/beacon.ex test/beacon_test.exs \
	lib/beacon/correlator.ex test/beacon/correlator_test.exs \
	lib/beacon/scanner.ex test/beacon/scanner_test.exs \
	lib/beacon/transformer.ex \
	lib/beacon/parser.ex test/beacon/parser_test.exs
VERBOSE = 0

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN) input/input.txt

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
