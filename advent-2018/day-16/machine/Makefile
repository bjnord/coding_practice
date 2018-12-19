BIN = ./machine
FILES = config/config.exs lib/machine.ex lib/machine/executor.ex \
	lib/machine/cpu.ex lib/machine/cli.ex mix.exs \
	test/machine_test.exs test/machine/cpu_test.exs \
	test/machine/executor_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Machine.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
