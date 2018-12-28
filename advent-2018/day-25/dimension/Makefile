BIN = ./dimension
FILES = config/config.exs lib/dimension/cli.ex lib/dimension.ex mix.exs test/test_helper.exs test/dimension_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Dimension.main(["input/example2.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) --parts=1 input/example2.txt && \
		$(BIN) --parts=1 input/example1.txt && \
		$(BIN) --parts=1 input/example4.txt && \
		$(BIN) --parts=1 input/example3.txt && \
		$(BIN) --parts=1 input/example8.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
