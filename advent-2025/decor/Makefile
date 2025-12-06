FILES = mix.exs test/test_helper.exs \
	config/config.exs config/dev.exs \
	lib/decor.ex test/decor_test.exs \
	lib/decor/cli.ex test/decor/cli_test.exs \
	lib/decor/grid.ex test/decor/grid_test.exs \
	lib/decor/math.ex test/decor/math_test.exs

.PHONY: test check doc console clean

#test: export PROPCHECK_VERBOSE=1
#test: export PROPCHECK_DETECT_EXCEPTIONS=0
test:
	@if [ -f _build/propcheck.ctex ]; then \
		( MIX_ENV=test mix propcheck.clean ); \
	fi
	mix test

check:
	mix dialyzer

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log
