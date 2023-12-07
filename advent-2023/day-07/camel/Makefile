BIN = ./camel
FILES = mix.exs test/test_helper.exs \
	lib/camel.ex test/camel_test.exs \
	lib/camel/hand.ex test/camel/hand_test.exs \
	lib/camel/parser.ex test/camel/parser_test.exs
VERBOSE = 0

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN) private/input.txt

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
