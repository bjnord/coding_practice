BIN = ./smoke
FILES = mix.exs test/test_helper.exs \
	lib/smoke.ex test/smoke_test.exs \
	lib/smoke/parser.ex test/smoke/parser_test.exs
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
