.PHONY: debug release test clippy doc clean

debug:
	cargo run

release:
	@cargo run --release

stringent:
	@cargo run --release -- -s input/input.txt

tolerant:
	@cargo run --release -- -t input/input.txt

test:
	cargo test

clippy:
	cargo clippy -- -Dclippy::pedantic

doc:
	cargo doc

clean:
	-@rm -rf target
