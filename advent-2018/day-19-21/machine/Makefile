BIN19 = ./machine
BIN21 = ./gadget
FILES = config/config.exs lib/machine.ex lib/machine/executor.ex \
	lib/machine/cpu.ex lib/machine/cli.ex lib/machine/register.ex \
	mix.exs test/machine_test.exs test/machine/executor_test.exs \
	test/machine/cpu_test.exs test/machine/register_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Machine.main(["input/example1.txt"])'

.PHONY: run
run: run19 run21

run19: $(BIN19)
	$(BIN19) --parts=1 input/input.txt

run21: $(BIN21)
	$(BIN21) --parts=12 input-day-21/input-fast.txt

disasm: $(BIN19) $(BIN21)
	$(BIN19) --disassemble input/input.txt && \
		$(BIN21) --disassemble input-day-21/input-fast.txt

decomp: $(BIN19) $(BIN21)
	$(BIN19) --decompile input/input.txt && \
		$(BIN21) --decompile input-day-21/input-fast.txt

examples: $(BIN19)
	$(BIN19) --parts=1 input/example1.txt && \
		$(BIN19) --parts=1 input/example2.txt

clean:
	rm -rf _build $(BIN19) $(BIN21)
veryclean:
	rm -rf _build $(BIN19) $(BIN21) *.out *.c *.asm

$(BIN19): $(FILES)
	mix escript.build

# apparently there's no built-in way to have more than one escript
# per mix project, so we're forced to take drastic measures
$(BIN21): $(FILES)
	mv mix.exs machine.exs && mv gadget.exs mix.exs
	mix escript.build
	mv mix.exs gadget.exs && mv machine.exs mix.exs
