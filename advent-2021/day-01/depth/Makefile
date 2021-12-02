.PHONY: run test

run:
	mix run -e 'Depth.part1(["input/input.txt"])' && mix run -e 'Depth.part2(["input/input.txt"])'

test:
	@rm -f _build/propcheck.ctex
	mix test
