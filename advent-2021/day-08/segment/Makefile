BIN = ./segment
FILES = mix.exs test/test_helper.exs \
	lib/segment.ex test/segment_test.exs \
	lib/segment/parser.ex test/segment/parser_test.exs
VERBOSE = 0

.PHONY: run test console clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) log/*.log

$(BIN): $(FILES)
	mix escript.build
