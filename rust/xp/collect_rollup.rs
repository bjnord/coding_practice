// This shows how `.collect()` "rollup" of the `Result` can be done with
// integers; it needs a little help to get `ParseIntError` into a `Box`.
//
// [reference](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/boxing_errors.html)

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

fn main() {
    let sequence = "1 4 9 16 25 36 49 64 81 100";
    let rules = parse_sequence(sequence);
    println!("good rules are {:?}", rules);

    let sequence = "1 4 x9 16 25 36 49 64 81 100";
    let rules = parse_sequence(sequence);
    println!("bad rules are {:?}", rules);
}

fn parse_sequence(sequence: &str) -> Result<Vec<usize>> {
    sequence.split(' ')
        .map(|rn| rn.parse::<usize>().map_err(|e| e.into()))
        .collect()
}
