BIN = ./trench
FILES = mix.exs test/test_helper.exs \
	lib/trench.ex test/trench_test.exs \
	lib/trench/image.ex test/trench/image_test.exs \
	lib/trench/parser.ex test/trench/parser_test.exs
VERBOSE = 0

.PHONY: run viz test doc console clean

run: $(BIN)
	$(BIN) input/input.txt

viz: $(BIN)
	$(BIN) --parts=0 --visualize input/input.txt

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
	rm -rf _build $(BIN) doc log/*.log viz/*.*

$(BIN): $(FILES)
	mix escript.build
