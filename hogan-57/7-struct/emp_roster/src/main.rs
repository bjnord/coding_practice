extern crate interact_io;
use emp_roster::{EmployeeRoster, RosterFilter, RosterSort};
use interact_io::readln;

fn main() {
    let mut roster = EmployeeRoster::from_file("roster.txt").unwrap();
    // TODO break filter/sort selection into separate functions
    let filt = readln::read_string("Filter records by name/position/separation: ").unwrap();
    let filter = match filt.chars().nth(0).unwrap_or('u') {
        'n' => {
            let pattern = readln::read_string("Name pattern: ").unwrap();
            RosterFilter::Name {pattern}
        },
        'p' => {
            let pattern = readln::read_string("Position pattern: ").unwrap();
            RosterFilter::Position {pattern}
        },
        's' => {
            let months = readln::read_u32("Separated within how many months? ").unwrap();
            RosterFilter::Separation {months}
        },
        _ => RosterFilter::Unfiltered,
    };
    roster.filter_by(filter);
    let sort = readln::read_string("Sort records by name/position/separation: ").unwrap();
    let sort_order = match sort.chars().nth(0).unwrap_or('u') {
        'n' => RosterSort::Name,
        'p' => RosterSort::Position,
        's' => RosterSort::Separation,
        _ => RosterSort::Unsorted,
    };
    roster.sort_by(sort_order);
    roster.print();
}
