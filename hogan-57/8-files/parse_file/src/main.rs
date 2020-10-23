use std::error::Error;
use std::fs;
use parse_file::{self, Record};

fn main() {
    let records = read_records("input/staff.csv").unwrap();
    dump_records(&records);
}

fn read_records(filename: &str) -> Result<Vec<Record>, Box<dyn Error>> {
    let contents = fs::read_to_string(filename)?;
    let mut records = Vec::new();
    for line in contents.lines() {
        let record = Record::parse(line)?;
        records.push(record);
    }
    Ok(records)
}

fn dump_records(records: &Vec<Record>) {
    let widths = parse_file::calc_widths(records);
    Record::dump_header(&widths);
    for record in records.iter() {
        record.dump(&widths);
    }
}
