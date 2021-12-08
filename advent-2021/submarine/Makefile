FILES = mix.exs test/test_helper.exs \
	lib/submarine.ex test/submarine_test.exs \
	lib/submarine/cli.ex test/submarine/cli_test.exs
VERBOSE = 0

.PHONY: test console release clean

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

console:
	iex -S mix

release:
	mix release

clean:
	rm -rf _build $(BIN)
