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

## Error Handling

MEME: Don't just mindlessly short-circuit error handling in the interest of implementation speed. Think carefully about whether a panic is acceptable, or if the error might happen in production and needs to be handled.

### Result

Some standard Rust methods return a `Result` enum, which is matched with:

```
match fn(...) {
    Ok(x) { println!("success, return={}", x); },
    Err(e) { println!("failure, error={}", e); },
}
```

`Result` can be short-circuited with `expect()` which will panic on error:

```
fn(...).expect("Failure");
```

### Option

Other methods return an `Option<T>` which is Rust's replacement for null pointers (a value which may or may not be present); this is matched with:

```
match fn(...) {
    Some(x) { println!("value present, x={}", x); },
    None { println!("no value present"); },
}
```

`Option<T>` can be short-circuited with `unwrap()` which will panic if no value is present:

```
let x = fn(...).unwrap();
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

## Constants

A [global array of strings](https://stackoverflow.com/a/32383866/291754) looks like this:

```
const BROWSERS: &'static [&'static str] = &["firefox", "chrome"];
```

## Importing

Convention with `use` is to import one level above for _functions_ and call them with the prefix:

```
use foo::bar;
...
bar::do_something();
```

but to import the item itself in the case of _structs_, _enums_, etc.:

```
use foo::bar::Bazkind;
...
let qux: Bazkind = bar::return_something();
```

To condense the code, several `use` lines can be nested inside braces:

```
use foo::bar::{baz, qux};
// (same as:)
use foo::bar::baz;
use foo::bar::qux;
```

and the `self` keyword stands for the same level:

```
use std::io::{self, Write};
// (same as:)
use std::io;
use std::io::Write;
```

## I/O

This [StackExchange answer](https://stackoverflow.com/a/39434382/291754) shows a concise way to stream the lines in a file:

```
use std::fs::File;
use std::io::{BufRead, BufReader};

        let reader = BufReader::new(File::open(filename).expect("Cannot open file"));
        for line in reader.lines() {
            // or shorter than matching: line.unwrap()
            match line {
                Ok(content) => { ... },
                Err(e) => { println!("line read error: {}", e); },
            }
        }
```

