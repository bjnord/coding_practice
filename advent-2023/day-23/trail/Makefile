BIN = ./trail
FILES = mix.exs test/test_helper.exs \
	lib/trail.ex test/trail_test.exs \
	lib/trail/maze.ex test/trail/maze_test.exs \
	lib/trail/parser.ex test/trail/parser_test.exs
VERBOSE = 0

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN) private/input.txt

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

$(BIN): $(FILES)
	mix escript.build
