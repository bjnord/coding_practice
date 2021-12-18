BIN = ./snailfish
FILES = mix.exs test/test_helper.exs \
	lib/snailfish.ex test/snailfish_test.exs \
	lib/snailfish/smath.ex test/snailfish/smath_test.exs \
	lib/snailfish/parser.ex test/snailfish/parser_test.exs
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