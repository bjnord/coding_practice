use statistics::ValueList;

fn main() {
    let value_list = ValueList::from_file("input.txt");
    //let value_list = ValueList::from_memory();
    println!("There are {} values.", value_list.count());
    // TODO output "Numbers: n1, n2, ... nn" using Display trait
    println!("The average is {}.", value_list.mean());
    println!("The minimum is {}.", value_list.min());
    println!("The maximum is {}.", value_list.max());
    println!("The standard deviation is {}.", value_list.std_dev());
}
