BIN = ./runes
FILES = mix.exs test/test_helper.exs \
	lib/runes.ex test/runes_test.exs \
	lib/runes/parser.ex test/runes/parser_test.exs
VERBOSE = 0

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN)

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
