BIN = ./reservoir
FILES = config/config.exs lib/reservoir/cli.ex lib/reservoir/flow.ex lib/reservoir.ex mix.exs test/test_helper.exs test/reservoir_test.exs test/reservoir/flow_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Reservoir.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt && \
		$(BIN) input/example2.txt && \
		$(BIN) input/example3.txt && \
		$(BIN) input/example4.txt && \
		$(BIN) input/example5.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
