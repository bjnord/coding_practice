BIN = ./depth
FILES = mix.exs test/test_helper.exs \
	lib/depth.ex test/depth_test.exs

.PHONY: run test clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@rm -f _build/propcheck.ctex
	mix test

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
