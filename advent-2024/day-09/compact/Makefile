BIN = ./compact
FILES = mix.exs test/test_helper.exs \
	lib/compact.ex test/compact_test.exs \
	lib/compact/disc.ex test/compact/disc_test.exs \
	lib/compact/parser.ex test/compact/parser_test.exs
VERBOSE = 0

.PHONY: run test check doc console clean

run: $(BIN)
	$(BIN) private/input.txt

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
