BIN = ./combat
FILES = config/config.exs lib/combat/cli.ex lib/combat.ex mix.exs test/test_helper.exs test/combat_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Combat.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt && \
		$(BIN) input/example2.txt && \
		$(BIN) input/example3.txt && \
		$(BIN) input/example4.txt && \
		$(BIN) input/example5.txt && \
		$(BIN) input/example6.txt && \
		$(BIN) input/example-reddit1.txt && \
		$(BIN) input/example-reddit2.txt

$(BIN): $(FILES)
	mix escript.build
