FILES = mix.exs test/test_helper.exs \
	lib/kingdom.ex test/kingdom_test.exs \
	lib/kingdom/cli.ex test/kingdom/cli_test.exs
VERBOSE = 0

.PHONY: test doc console clean

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
