BIN = ./packet
FILES = mix.exs test/test_helper.exs \
	lib/packet.ex test/packet_test.exs \
	lib/packet/decoder.ex test/packet/decoder_test.exs \
	lib/packet/parser.ex test/packet/parser_test.exs
VERBOSE = 0

.PHONY: run test doc console clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@if [ -f _build/propcheck.ctex ]; then \
		MIX_ENV=test mix propcheck.clean; \
	fi
	PROPCHECK_VERBOSE=$(VERBOSE) mix test

doc:
	mix docs

console:
	iex -S mix

clean:
	rm -rf _build $(BIN) doc log/*.log

$(BIN): $(FILES)
	mix escript.build
