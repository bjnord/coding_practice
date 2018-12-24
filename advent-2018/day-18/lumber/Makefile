BIN = ./lumber
FILES = config/config.exs mix.exs test/test_helper.exs \
	lib/lumber/cli.ex lib/lumber.ex test/lumber_test.exs \
	lib/yard.ex test/yard_test.exs \

.PHONY: test
test:
	mix test && mix run -e 'Lumber.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
