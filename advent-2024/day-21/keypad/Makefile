BIN = ./keypad
FILES = mix.exs test/test_helper.exs \
	lib/keypad.ex test/keypad_test.exs \
	lib/keypad/directional.ex test/keypad/directional_test.exs \
	lib/keypad/numeric.ex test/keypad/numeric_test.exs \
	lib/keypad/parser.ex test/keypad/parser_test.exs

.PHONY: run test check doc console clean

run: $(BIN)
	$(BIN) private/input.txt

#test: export PROPCHECK_VERBOSE=1
#test: export PROPCHECK_DETECT_EXCEPTIONS=0
test:
	@if [ -f _build/propcheck.ctex ]; then \
		( MIX_ENV=test mix propcheck.clean ); \
	fi
	mix test

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
