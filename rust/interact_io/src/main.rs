use interact_io::readln;

fn main() {
    let n = readln::read_i32("Enter a signed integer: ").unwrap();
    println!("Your signed integer was: {}", n);
    let n = readln::read_i32_range("Enter a signed integer between -10 and 10: ", -10, 10).unwrap();
    println!("Your signed integer was: {}", n);
    let n = readln::read_u32("Enter an unsigned integer: ").unwrap();
    println!("Your unsigned integer was: {}", n);
    let n = readln::read_f64("Enter a floating-point number: ").unwrap();
    println!("Your floating-poing number was: {}", n);
    let s = readln::read_string("Enter a string: ").unwrap();
    println!("Your string was: [{}]", s);
}
