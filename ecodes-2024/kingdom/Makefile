FILES = mix.exs test/test_helper.exs \
	lib/kingdom.ex test/kingdom_test.exs \
	lib/kingdom/cli.ex test/kingdom/cli_test.exs \
	lib/kingdom/grid.ex test/kingdom/grid_test.exs
VERBOSE = 0

.PHONY: test check doc console clean

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
