# Things I've Learned About Rust

## See Also

- [Rust Language Cheat Sheet](https://cheats.rs/)

## Terms

- "turbofish" refers to the `::<>` type coercion syntax

## Useful Crates

- [itertools](https://docs.rs/itertools/) is the iterator super-charger (see more below)
- [maplit](https://docs.rs/maplit/) provides a `hashmap!{}` macro

## Pretty Printing

1. Macros end with the bang character. The `println!()` macro outputs to `stdout`, while `eprintln!()` outputs to `stderr`.

1. In the statement `println!("Number is {}.", a);` the `{}` part (with nothing in it) uses the `Display` _trait_ of the referent; this is defined for builtin types like `u32` and `String`. `Display` is meant for end-user formatting.

1. Some compound types also have a `Debug` trait which is accessed using `{:?}` (show inline) or `{:#?}` (one attribute per line). `Debug` is meant for developer output (pretty-printing). You can _derive_ a `Debug` trait with this directive (which applies only to the `struct` that follows it):

        #[derive(Debug)]
        struct Position {
            y: i32,
            x: i32,
        }
        ...
        let pos = Position {y: 2, x: -1};
        println!("position is {:?}", pos);

1. Here's a useful function to print the type of a variable:

        // <https://stackoverflow.com/a/58119924/291754>
        fn print_type_of<T>(_: &T) {
            println!("type {}", std::any::type_name::<T>())
        }
        ...
        print_type_of(&foo);

## Function Return Type

Tip: As an alternative to consulting the documentation, you can "ask the compiler" what a function returns by inserting a known-wrong type and trying to compile:

```
error[E0308]: mismatched types
 --> src/main.rs:4:18
  |
4 |     let f: u32 = File::open("hello.txt");
  |            ---   ^^^^^^^^^^^^^^^^^^^^^^^ expected `u32`, found enum `std::result::Result`
  |            |
  |            expected due to this
  |
  = note: expected type `u32`
             found enum `std::result::Result<std::fs::File, std::io::Error>`
```

## Structures

The `impl` of a `struct` can use `Self` to refer to its own name; this keeps it DRY if you decide to rename it later.

## Error Handling

MEME: Don't just mindlessly short-circuit error handling in the interest of implementation speed. Think carefully about whether a panic is acceptable, or if the error might happen in production and needs to be handled.

### Result

Some standard Rust methods return a `Result<T, E>` enum, which can be matched with:

```
match fn(...) {
    Ok(x) => println!("success, return={}", x),
    Err(e) => println!("failure, error={:?}", e),
}
```

(The "arms" of the `match` are _closures_. They can be a bare expression, which will be returned from `match`. They can also be a block (in braces) which ends with an expression.)

`Result` can be short-circuited with `unwrap()` which will panic on error. `expect()` does the same thing, but allows you to provide the text of the panic message:

```
let r = fn(...).unwrap();
let r = fn(...).expect("Custom failure text");
```

`Result` also has methods `unwrap_or()` and `unwrap_or_else()`; the latter takes a closure for the error case:

```
let r = fn(...).unwrap_or(value);
let r = fn(...).unwrap_or_else(|error| {...});
```

#### Propagating Results

Rust has the `?` operator which provides a concise way of propagating errors by returning them up the chain. In this example, in the `Ok` case, `?` will return the value to the `buf` assignment, and flow will continue to the next statement; in the `Err` case, `?` will cause `my_read_file()` to immediately return an error result to the caller:

```
fn my_read_file(file: &str) -> Result<String, io::Error> {
    let buf = fs::read(file)?;
    ...
}
```

#### Simplifying Result With a Custom Type and Error

[This article](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/boxing_errors.html) shows how to add a type, such that you can replace `Result<T, ...>` with just `Result<T>` everywhere in your code. When the error portion of `Result` is `Box<dyn error::Error>` that cleans things up quite a bit.

It also shows how to create a custom error (they call it `EmptyVec`), and how to define traits for it, such that a custom boxed error is easy to create when needed.

#### Custom Errors

The [custom\_error](https://crates.io/crates/custom_error/1.7.1) crate gives you a macro that supplies all the boilerplate needed for a custom error enumeration (note the lack of commas when the macro is used):

```
use custom_error::custom_error;

custom_error!{#[derive(PartialEq)]
    SolutionError
    NotFound{expected: i32} = "no solution found for {expected}"
}

fn find_solution(values: Vec<i32>, choose: usize, expected: i32) -> Result<Vec<i32>, SolutionError> {
    // ...
    return Err(SolutionError::NotFound{expected});
}

    #[test]
    fn test_no_solution_found() {
        // ...
        let result = find_solution(values, 2, EXPECTED);
        assert_eq!(result.err().unwrap(), SolutionError::NotFound{expected: EXPECTED});
    }
```

### Option

Other methods return an `Option<T>` which is Rust's replacement for null pointers (a value which may or may not be present); this is matched with:

```
match fn(...) {
    Some(x) => { println!("value present, x={}", x); },
    None => { println!("no value present"); },
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

This [StackExchange answer](https://stackoverflow.com/a/39434382/291754) shows one way to stream the lines in a file:

```
use std::fs::File;
use std::io::{BufRead, BufReader};

        let reader = BufReader::new(File::open(filename).expect("Cannot open file"));
        for line in reader.lines() {
            // or shorter than matching: line.unwrap()
            match line {
                Ok(content) => ...,
                Err(e) => println!("line read error: {}", e),
            }
        }
```

If you do want to read a whole file into a string, Rust provides this method:

```
use std::fs;

let s: String = fs::read_to_string("filename.txt").unwrap();
```

### Delegating Parsing to the `FromStr` Trait

The `str::parse()` function uses the `FromStr` trait to do its work; as long as Rust can infer the type wanted, it calls the appropriate `FromStr`. An example is:

        type Result<MyStruct> = result::Result<MyStruct, Box<dyn error::Error>>;

        impl FromStr for MyStruct {
            type Err = Box<dyn error::Error>;
            fn from_str(line: &str) -> Result<Self> {
                // ...
            }
        }

Once this trait is defined, and generates its own errors (bad format, etc.), it becomes very easy to read a whole file, propagating any error to the caller:

        pub fn read_from_file(path: &str) -> Result<Vec<MyStruct>> {
            let s: String = fs::read_to_string(path)?;
            s.lines().map(str::parse).collect()
        }

Rust knows it's returning a vector of `MyStruct`, so it can push that type inwards to the `parse()` call to know what it needs. Collecting `Error` to the returned `Result` is described by the "Fail the entire operation with collect()" section of [this page](https://doc.rust-lang.org/rust-by-example/error/iter_result.html), which also has other options for handling errors when iterating.

## Strings

### Concatenation

The Rust `+` operator is a bit weird-looking and weird-behaving:

```
let s3 = s1 + &s2;
```

The operator's first argument is a `String` but its second argument is a `&str` (string slice). And as with all Rust, because `s1` is not a reference, the concatenation operation takes ownership of `s1` but then does not return it, so `s1` is no longer usable afterward. It is more efficient however than making a completely new copy.

To avoid the weirdness (at the cost of efficiency), we can use the `format!()` macro, which does not taken ownership of its arguments:

```
let s3 = format!("{}{}", s1, s2);
```

### Characters

Rust characters (_e.g._ `'b'`) are 4-byte Unicode values.

Rust strings are also Unicode, but the `String` type is implemented as a `Vec<u8>` which means that foundationally, a byte stream is being stored (UTF-8?).

1. You can't use array indexing like `s[1]` to get "one letter" of a string.
1. When you use a slice (range) `s[0..2]`, or alternatively the `s.bytes()` method, you are getting **single bytes**, which for multi-byte strings may not be what you want.
1. To get the 8-/16-/24-/32-bit **scalar values** (ordinal code of each Unicode char), use the `s.chars()` method. But **note** that this will separate out diacritics and combining characters, which are not sensible on their own.
1. To get **graphemes** (fully-combined characters), you have to use crate software outside the Rust standard library. (Graphemes are really what we would call "letters" when looking at words on a page.)

### Parsing

If you just need to tokenize a `String` into variables, `.collect_tuple()` is simpler than using a regex:

```
let words = line.split_whitespace();
let (name, phone, email) = words.collect_tuple().unwrap();
```

The `.parse()` method of `String` can convert it to another type:

```
let n: i32 = number.parse().unwrap();
// or:
let n = number.parse::<i32>().unwrap();
```

The [scan\_fmt](https://docs.rs/scan_fmt/) crate provides `scanf()`-like functionality that combines tokenizing and type conversion.

## Using Iterators

1. MEME: Length of a vector is `vec.len()` (think math), count of items in iterator is `iter.count()` (and it walks the iterator to do so; think counting people as they slowly walk by).
1. By using `.enumerate()` on an iterator, you can get the index of each iterated value inline; `.enumerate()` returns `(index, value)` tuples.

### For Loop

MEME: Review the `for A in B` [definition in the language reference](https://doc.rust-lang.org/reference/expressions/loop-expr.html#iterator-loops) and [this StackExchange question and answer](https://stackoverflow.com/questions/27224927/what-is-the-exact-definition-of-the-for-loop-in-rust):

1. The `B` after `in` must be convertable to `Iterator<T>`.
1. The `A` after `for` is not a variable, it is an _"irrefutable pattern"_ that binds values of type T ("irrefutable" meaning it must work for all items passed to it).
1. Since `A` is a pattern: Given `ref_iter` which is `Iterator<&i32>`, the `&n` in `for &n in ref_iter` is _destructuring_ the iterated value, binding the `i32` (pointed-to) value into `n`. Alternatively, you can use `for n in ref_iter` and then dereference with `*n`.
1. By default `for` uses the `.into_iter()` form (see below), which means the `B` object will no longer be usable afterward; use `&B` to lend a reference to it.

### The Three Iterator Methods

1. `.into_iter()` works for anything that implements the `IntoIterator` trait. The trait implementation can be for any/all of `T`, `&T`, or `&mut T`, and the correct one is chosen for the calling context. This form **consumes** the collection object (borrows and doesn't return it); think "turn the source _into_ an iterator".
1. `.iter()` simply returns an iterator giving _immutable_ references over the collection.
1. `.iter_mut()` simply returns an iterator giving _mutable_ references over the collection.

### Map, Filter, Reduce

1. In Rust, reduce is called `.fold()`: `let sum: i32 = iter.fold(0, |acc, x| acc + x);`
1. `.map()` `.filter()` and `.fold()` operate on an iterator.
1. `.fold()` returns the final value. `.map()` and `.filter()` seem to return some kind of proxy object; calling `.collect()` on the proxy yields a vector.
1. Therefore transforming vector `x` into vector `y` looks like: `x.into_iter().map(|v| ...).collect()`.

### Min, Max

1. Rust provides `.min()` and `.max()` for an iterator; note that it returns `Option<&T>` for a vector, which means the result has to be unwrapped and dereferenced: `*values_vector.iter().min().unwrap()`
1. Rust also provides `.min_by()` and `.max_by()` which take a comparison function, useful for complex objects.

### Itertools

The [itertools](https://crates.io/crates/itertools) crate has a lot of extra functionality for iterators, including:

- `.permutations()` and `.combinations()` which return another iterator that produces all permutations/combinations of the original
- `.tuple_permutations()` and `.tuple_combinations()` which return vectors rather than iterators
- `.tuple_windows(n)` which returns an iterator that produces tuples of n; _e.g._ with _2_ it will return `(1st_el, 2nd_el)`, then `(2nd_el, 3rd_el)`, etc. (this is similar to `Vec` `.windows(n)` which produces a new vector)

## Testing

Rust's test system will soon be able to perform [benchmarking measurements](https://doc.rust-lang.org/unstable-book/library-features/test.html) for testing performance. As of Dec 2020 (Rust v1.46.0) this is currently an "unstable" feature.
