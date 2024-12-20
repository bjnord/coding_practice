BIN = ./race
FILES = mix.exs test/test_helper.exs \
	lib/race.ex test/race_test.exs \
	lib/race/graph.ex test/race/graph_test.exs \
	lib/race/parser.ex test/race/parser_test.exs
VERBOSE = 0

.PHONY: run test check bench doc console clean

run: $(BIN)
	$(BIN) private/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

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
