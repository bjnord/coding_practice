BIN = ./dish
FILES = mix.exs test/test_helper.exs \
	lib/dish.ex test/dish_test.exs \
	lib/dish/parser.ex test/dish/parser_test.exs \
	lib/dish/platform.ex test/dish/platform_test.exs
VERBOSE = 0

.PHONY: run test time profile doc console clean

run: $(BIN)
	$(BIN) private/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

time: $(BIN)
	time $(BIN) --parts=2 private/input.txt

profile:
	mix profile.eprof -e 'Dish.part2("private/input.txt")'

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log

$(BIN): $(FILES)
	mix escript.build
