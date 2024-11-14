BIN = ./potions
FILES = mix.exs test/test_helper.exs \
	lib/potions.ex test/potions_test.exs
VERBOSE = 0

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN) private/everybody_codes_e2024_q01_p1.txt

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
