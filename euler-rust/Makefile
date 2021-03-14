.PHONY: debug release test test-ignored clippy doc clean

debug:
	cargo run

release:
	@cargo run --release

test:
	cargo test

test-ignored:
	cargo test -- --ignored

clippy:
	cargo clippy -- -Dclippy::pedantic

doc:
	cargo doc

clean:
	-@rm -rf target
