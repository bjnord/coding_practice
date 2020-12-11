.PHONY: debug release test clippy doc clean

debug:
	cargo run

release:
	@cargo run --release

test:
	cargo test

clippy:
	cargo clippy -- -Dclippy::pedantic

doc:
	cargo doc

clean:
	-@rm -rf target
