BIN = ./machine
FILES = config/config.exs lib/machine.ex lib/machine/executor.ex \
	lib/machine/cpu.ex lib/machine/cli.ex lib/machine/register.ex \
	mix.exs test/machine_test.exs test/machine/executor_test.exs \
	test/machine/cpu_test.exs test/machine/register_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Machine.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) --parts=1 input/example1.txt && \
		$(BIN) --parts=1 input/example2.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
