use std::error::Error;
use std::fs;

fn main() {
    let mut names = read_names("input/names.txt").unwrap();
    names.sort();
    output_names(&names);
}

fn read_names(filename: &str) -> Result<Vec<String>, Box<dyn Error>> {
    let contents = fs::read_to_string(filename)?;
    let mut names = Vec::new();
    for line in contents.lines() {
        names.push(String::from(line));
    }
    Ok(names)
}

fn output_names(names: &Vec<String>) {
    println!("Total of {} names", names.len());
    println!("-----------------");
    for name in names {
        println!("{}", name);
    }
}
