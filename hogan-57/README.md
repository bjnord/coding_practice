# Things I've Learned About Rust

## Pretty Printing

1. In the statement `println!("Number is {}.", a);` the `{}` part (with nothing in it) uses the `Display` _trait_ of the referent; this is defined for builtin types like `u32` and `String`. `Display` is meant for end-user formatting.

1. Some compound types also have a `Debug` trait which is accessed using `{:?}` (show inline) or `{:#?}` (one attribute per line). `Debug` is meant for developer output (pretty-printing). You can _derive_ a `Debug` trait with this directive (which applies only to the `struct` that follows it):

```
#[derive(Debug)]
struct Position {
    y: i32,
    x: i32,
}
...
let pos = Position {y: 2, x: -1};
println!("position is {:?}", pos);
```

1. Here's a useful function to print the type of a variable:

```
// <https://stackoverflow.com/a/58119924/291754>
fn print_type_of<T>(_: &T) {
    println!("type {}", std::any::type_name::<T>())
}
...
print_type_of(&foo);
```

## Regular Expressions

To avoid (re)compiling the regex at runtime, best practices is to use the `lazy_static` macro (see [Avoid compiling the same regex in a loop](https://docs.rs/regex/1.3.9/regex/#example-avoid-compiling-the-same-regex-in-a-loop)):

```
     lazy_static! {
         static ref NUM_RE: Regex = Regex::new(r"^\d+$").unwrap();
     }
     if NUM_RE.is_match("12345") {
         ...
     }
```
