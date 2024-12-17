BIN = ./computer
FILES = mix.exs test/test_helper.exs \
	lib/computer.ex test/computer_test.exs \
	lib/computer/parser.ex test/computer/parser_test.exs
VERBOSE = 0
INPUT = private/input.txt

.PHONY: run pry test deasm check doc console clean

run: $(BIN)
	$(BIN) $(INPUT)

pry: $(BIN)
	iex --dbg pry -S mix eval 'Computer.main(["--parts=1", "example/example.txt"])'

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

deasm: $(BIN)
	$(BIN) --verbose --parts=0 $(INPUT)

check:
	mix dialyzer

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log

$(BIN): $(FILES)
	mix escript.build
