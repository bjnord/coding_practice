use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let values = read_values("input/input.txt");
    let solution = find_solution(values);
    println!("== PART 1 ==");
    println!("{} + {} = 2020", solution[0], solution[1]);
    println!("{} * {} = {}", solution[0], solution[1], solution[0] * solution[1]);
}

fn read_values(filename: &str) -> Vec<i32> {
    let reader = BufReader::new(File::open(filename).expect("Cannot open file"));
    let mut values = Vec::new();
    for line in reader.lines() {
        match line {
            Ok(content) => values.push(content.parse::<i32>().unwrap()),
            Err(e) => eprintln!("line read error: {}", e),
        }
    }
    values
}

fn find_solution(mut values: Vec<i32>) -> Vec<i32> {
    while !values.is_empty() {
        let v = values.pop().unwrap();
        for v2 in values.iter() {
            if v + *v2 == 2020 {
                return vec![v, *v2]
            }
        }
    }
    vec![]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_find_solution() {
        let values = read_values("input/example1.txt");
        let solution = find_solution(values);
        assert_eq!(2, solution.len());
        assert_eq!(514579, solution[0] * solution[1]);
    }
}
