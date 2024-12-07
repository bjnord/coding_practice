BIN = ./guard
FILES = mix.exs test/test_helper.exs \
	lib/guard.ex test/guard_test.exs \
	lib/guard/parser.ex test/guard/parser_test.exs
CONFIGS = config/config.exs config/dev.exs \
	config/test.exs config/prod.exs
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

$(BIN): $(FILES) $(CONFIGS)
	mix escript.build
