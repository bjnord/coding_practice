.PHONY: debug release test clippy doc clean

debug:
	cargo run

release:
	@cargo run --release

test:
	cargo test

clippy:
	cargo clippy -- -D clippy::pedantic -A clippy::uninlined_format_args

doc:
	cargo doc

clean:
	-@rm -rf target
