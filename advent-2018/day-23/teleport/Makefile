BIN = ./teleport
FILES = config/config.exs mix.exs test/test_helper.exs \
	lib/nanobot.ex test/nanobot_test.exs \
	lib/teleport.ex test/teleport_test.exs \
	lib/teleport/cli.ex \
	lib/teleport/priority_queue.ex test/teleport/priority_queue_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Teleport.main(["input/example2.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) --parts=1 input/example1.txt && \
		$(BIN) --parts=2 input/example2.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
