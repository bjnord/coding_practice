BIN = ./logic
FILES = mix.exs test/test_helper.exs \
	lib/logic.ex test/logic_test.exs \
	lib/logic/unit.ex test/logic/unit_test.exs \
	lib/logic/parser.ex test/logic/parser_test.exs
VERBOSE = 0

.PHONY: run matchsticks test doc console clean

run: $(BIN)
	$(BIN) input/input.txt

matchsticks: $(BIN)
	$(BIN) --parts=3 --verbose input/matchsticks.txt

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
