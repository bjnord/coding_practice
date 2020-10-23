use std::error::Error;
use std::fs;

fn main() {
    let records = read_records("input/staff.csv").unwrap();
    dump_records(&records);
}

struct Record {
    l_name: String,
    f_name: String,
    salary: u32,
}

impl Record {
    fn new(line: &str) -> Result<Record, Box<dyn Error>> {
        let fields: Vec<&str> = line.split(",").collect();
        match fields.len() {
            3 => Ok(Record {
                l_name: String::from(fields[0]),
                f_name: String::from(fields[1]),
                salary: String::from(fields[2]).parse::<u32>()?,
            }),
            _ => Err(String::from("invalid line").into()),
        }
    }

    fn dump_header() {
        println!("Last     First     Salary");
        println!("-------------------------");
    }

    fn dump(&self) {
        println!("{ln:<lw$}{gn:<gw$}{s}", ln=self.l_name, lw=9, gn=self.f_name, gw=10, s=self.salary);
    }
}

fn read_records(filename: &str) -> Result<Vec<Record>, Box<dyn Error>> {
    let contents = fs::read_to_string(filename)?;
    let mut records = Vec::new();
    for line in contents.lines() {
        let record = Record::new(line)?;
        records.push(record);
    }
    Ok(records)
}

fn dump_records(records: &Vec<Record>) {
    Record::dump_header();
    for record in records.iter() {
        record.dump();
    }
}
