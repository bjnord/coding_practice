BIN = ./pluto
FILES = mix.exs test/test_helper.exs \
	lib/pluto.ex test/pluto_test.exs \
	lib/pluto/parser.ex test/pluto/parser_test.exs

.PHONY: run test check bench doc console clean

run: $(BIN)
	$(BIN) private/input.txt

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

$(BIN): $(FILES)
	mix escript.build
