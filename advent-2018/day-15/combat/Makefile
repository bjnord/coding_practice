BIN = ./combat
FILES = config/config.exs lib/combat/cli.ex lib/combat.ex mix.exs test/test_helper.exs test/combat_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Combat.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) --parts 1 input/example1.txt && \
		$(BIN) --parts 1 input/example2.txt && \
		$(BIN) --parts 1 input/example3.txt && \
		$(BIN) --parts 1 input/example4.txt && \
		$(BIN) --parts 1 input/example5.txt && \
		$(BIN) --parts 1 input/example6.txt && \
		$(BIN) --parts 1 input/example-reddit1.txt && \
		$(BIN) --parts 1 input/example-reddit2.txt && \
		$(BIN) --parts 1 input/example-reddit3.txt

# NB puzzle doesn't give part 2 solution for input/example2.txt
p2-examples: $(BIN)
	$(BIN) --parts 2 input/example1.txt && \
		$(BIN) --parts 2 input/example3.txt && \
		$(BIN) --parts 2 input/example4.txt && \
		$(BIN) --parts 2 input/example5.txt && \
		$(BIN) --parts 2 input/example6.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
