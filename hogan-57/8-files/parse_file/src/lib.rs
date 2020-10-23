use num_format::{Locale, ToFormattedString};
use std::error::Error;

pub struct Record {
    l_name: String,
    f_name: String,
    salary: u32,
}

impl Record {
    pub fn parse(line: &str) -> Result<Record, Box<dyn Error>> {
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

    fn new() -> Result<Record, Box<dyn Error>> {
        Ok(Record {l_name: String::new(), f_name: String::new(), salary: 0})
    }

    fn fmt_dollars(dollars: u32) -> String {
        format!("${}", dollars.to_formatted_string(&Locale::en))
    }

    pub fn dump_header(widths: &Vec<usize>) {
        println!("{ln:<lw$}{gn:<gw$}{sal:>sw$}", ln="Last", lw=widths[0]+1, gn="First", gw=widths[1]+1, sal="Salary", sw=widths[2]+1);
        println!("{}", "-".repeat(widths[0]+widths[1]+widths[2]+3));
    }

    // "Make each column one space longer than the longest
    // value in the column."
    pub fn dump(&self, widths: &Vec<usize>) {
        let salary_str = Record::fmt_dollars(self.salary);
        println!("{ln:<lw$}{gn:<gw$}{sal:>sw$}", ln=self.l_name, lw=widths[0]+1, gn=self.f_name, gw=widths[1]+1, sal=salary_str, sw=widths[2]+1);
    }

    fn field_widths(&self) -> Vec<usize> {
        let salary_str = Record::fmt_dollars(self.salary);
        vec![self.l_name.len(), self.f_name.len(), salary_str.len()]
    }
}

pub fn calc_widths(records: &Vec<Record>) -> Vec<usize> {
    let mut widths = Record::new().unwrap().field_widths();
    for record in records.iter() {
        let r_widths = record.field_widths();
        for (i, &width) in r_widths.iter().enumerate() {
            if width > widths[i] {
                widths[i] = width;
            }
        }
    }
    widths
}
