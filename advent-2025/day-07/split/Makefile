BIN = ./split
FILES = mix.exs test/test_helper.exs \
	config/config.exs config/dev.exs \
	lib/split.ex test/split_test.exs \
	lib/split/parser.ex test/split/parser_test.exs
VERBOSE = 0

.PHONY: run test check bench doc format console clean

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

format:
	mix format

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log

$(BIN): $(FILES)
	mix escript.build
