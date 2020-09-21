extern crate interact_io;
use emp_roster::{EmployeeRoster, RosterSort};
use interact_io::readln;

fn main() {
    let mut roster = EmployeeRoster::from_file("roster.txt").unwrap();
    let sort = readln::read_string("Sort records by name/position/separation: ").unwrap();
    let sort_order = match sort.chars().nth(0).unwrap() {
        'n' => RosterSort::Name,
        'p' => RosterSort::Position,
        's' => RosterSort::Separation,
        _ => RosterSort::Unsorted,
    };
    roster.sort_by(sort_order);
    roster.print();
}
