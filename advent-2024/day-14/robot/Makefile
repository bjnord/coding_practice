BIN = ./robot
FILES = mix.exs test/test_helper.exs \
	lib/robot.ex test/robot_test.exs \
	lib/robot/parser.ex test/robot/parser_test.exs

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
