FILES = mix.exs test/test_helper.exs \
	lib/history.ex test/history_test.exs \
	lib/history/cli.ex test/history/cli_test.exs \
	lib/history/grid.ex test/history/grid_test.exs \
	lib/history/math.ex test/history/math_test.exs

.PHONY: test check bench doc console clean

#test: export PROPCHECK_VERBOSE=1
#test: export PROPCHECK_DETECT_EXCEPTIONS=0
test:
	@if [ -f _build/propcheck.ctex ]; then \
		( MIX_ENV=test mix propcheck.clean ); \
	fi
	mix test

check:
	mix dialyzer

bench:
	mix run bench/run.exs | tee log/bench.out

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log
