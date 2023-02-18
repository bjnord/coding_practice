# Advent of Code 2015 in Rust

I used stable `rustc 1.67.1` to develop this year (no unstable/nightly features).

I'm not using the [cargo-aoc crate](https://crates.io/crates/cargo-aoc). But each day emits similar output, with times for generating and running.

## My Puzzle Input

At Eric Wastl's request, my `input.txt` is encrypted using [git-crypt](https://github.com/AGWA/git-crypt). You can copy your own on top of it.

## Make Targets

There's a top-level `Makefile` that runs the individual day targets recursively.

- `make test` compiles and runs tests
- `make` compiles and runs the `debug` target
- `make release` compiles and runs the `release` target
  - dramatically faster than the `debug` target
- `make doc` creates the documentation
- `make clippy` runs clippy in pendantic mode
  - For some reason it produces more output if preceded by `make clean`
- `make clean` removes the `target/` directory

## Flamegraphs

If `perf` is installed, `cargo` can produce simple [flamegraphs](https://github.com/flamegraph-rs/flamegraph#systems-performance-work-guided-by-flamegraphs) to show where the time is being taken up.

    $ cargo install flamegraph
    $ sudo yum install -y perf
    # may need this to run as non-root:
    $ echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid

    # add to Cargo.toml:
    [profile.release]
    debug = true

    # produces flamegraph.svg:
    $ cargo flamegraph

## Memory Usage

Similarly see [this Reddit post](https://www.reddit.com/r/adventofcode/comments/k9btf6/2020_day_8_rust_visualising_memory_usage/) for measuring memory usage.

## Daily README

I like having each day's `README.md` match the puzzle description. I save it as HTML and then use Pandoc:

    pandoc README.html -t markdown --atx-headers -o README.md

1. I remove the `---` from the headers, adding `## Part One` at the top.
1. I switch the emphasis from single asterisks to double, so it comes out bold as in the HTML.
