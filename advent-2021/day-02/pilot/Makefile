BIN = ./pilot
FILES = mix.exs test/test_helper.exs \
	lib/pilot.ex test/pilot_test.exs \
	lib/pilot/cli.ex test/pilot/cli_test.exs

.PHONY: run test clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@rm -f _build/propcheck.ctex
	mix test

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
