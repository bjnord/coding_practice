FILES = mix.exs test/test_helper.exs \
	lib/submarine.ex test/submarine_test.exs \
	lib/submarine/cli.ex test/submarine/cli_test.exs

.PHONY: test release clean

test:
	@rm -f _build/propcheck.ctex
	mix test

release:
	mix release

clean:
	rm -rf _build $(BIN)
