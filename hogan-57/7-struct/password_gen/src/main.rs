fn main() {
    let pw = password_gen::generate(8, 2, 2);
    println!("Your password is");
    println!("{}", pw);
}
