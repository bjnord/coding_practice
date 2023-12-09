FILES = mix.exs test/test_helper.exs \
	lib/snow.ex test/snow_test.exs \
	lib/snow/cli.ex test/snow/cli_test.exs \
	lib/snow/snow_math.ex test/snow/snow_math_test.exs
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
