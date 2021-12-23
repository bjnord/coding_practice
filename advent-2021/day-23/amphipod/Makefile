BIN = ./amphipod
FILES = mix.exs test/test_helper.exs \
	lib/amphipod.ex test/amphipod_test.exs \
	lib/amphipod/board.ex test/amphipod/board_test.exs \
	lib/amphipod/game.ex test/amphipod/game_test.exs \
	lib/amphipod/parser.ex test/amphipod/parser_test.exs
VERBOSE = 0

.PHONY: run test cprof doc console clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test --exclude=pending

# NB this is supposed to work for `eprof` and `fprof` too
#    but the latter crashes for me
cprof:
	mix profile.cprof -e 'Amphipod.part1("input/input.txt")' >log/cprof.out

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log log/cprof.out

$(BIN): $(FILES)
	mix escript.build
