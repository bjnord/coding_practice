BIN = ./door
FILES = config/config.exs mix.exs test/test_helper.exs \
	lib/door.ex test/door_test.exs \
	lib/door/cli.ex test/door/cli_test.exs \
	lib/door/input_parser.ex test/door/input_parser_test.exs \
	lib/door/path.ex test/door/path_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Door.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) --parts 1 input/example1.txt && \
		$(BIN) --parts 1 input/example2.txt && \
		$(BIN) --parts 1 input/example3.txt && \
		$(BIN) --parts 1 input/example4.txt && \
		$(BIN) --parts 1 input/example5.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
