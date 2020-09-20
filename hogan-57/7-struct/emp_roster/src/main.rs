use emp_roster::EmployeeRoster;

fn main() {
    let roster = EmployeeRoster::from_file("roster.txt").unwrap();
    println!("{} employees found in roster.", roster.len());
}
