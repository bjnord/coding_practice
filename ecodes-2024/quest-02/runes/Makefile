BIN = ./runes
FILES = mix.exs test/test_helper.exs \
	lib/runes.ex test/runes_test.exs \
	lib/runes/artifact.ex test/runes/artifact_test.exs \
	lib/runes/parser.ex test/runes/parser_test.exs
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
