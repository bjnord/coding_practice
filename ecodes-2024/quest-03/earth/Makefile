BIN = ./earth
FILES = mix.exs test/test_helper.exs \
	lib/earth.ex test/earth_test.exs \
	lib/earth/parser.ex test/earth/parser_test.exs
VERBOSE = 0

.PHONY: run test check doc console clean

run: $(BIN)
	$(BIN)

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

check:
	mix dialyzer

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log

$(BIN): $(FILES)
	mix escript.build
