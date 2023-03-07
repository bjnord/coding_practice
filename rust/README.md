# Things I've Learned About Rust

## See Also

- [Rust Language Cheat Sheet](https://cheats.rs/)
- [Idiomatic Rust](https://github.com/mre/idiomatic-rust)

## Setup

- Rust is installed/updated with the `rustup` tool
  - `rustup show` shows active toolchains/channels (and what version)
  - `rustup check` + `rustup update` (to update version)
- Rust has _channels_ (`stable`, `beta`, `nightly`)
  - and `rustup toolchain <cmd>` can be used to install a specific version
    - _i.e._ `1.47` and `1.47.0` can be used as a channel name
- What version is active? `rustc --version` + `cargo --version`

## Terms

- "turbofish" refers to the `::<>` type coercion syntax

## Installing Rust

The Rust book says "The [Rustup](https://rustup.rs/) tool has become the recommended way to install Rust" and this is how I did it for AoC 2020.
- the [install page](https://www.rust-lang.org/tools/install) has a `curl` one-liner to install `rustup`
- `rustup toolchain install stable` installs the `stable` "release channel"
- `rustup show` shows what's currently installed

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

### Traits

See [this helful answer](https://stackoverflow.com/a/31013156/291754) on the difference between `Copy` and `Clone`:

- `Copy` is for things with a size known at compile-time, and which can be accurately duplicated using `memcpy`. Generally you can only use this for structures with primitive types like `i32`.
- `Clone` allows the implementer to do arbitrarily complicated operations to create a new `T` that's a functional duplicate (within the context of this app). It could be shallow or deep.

_from "Rust Brain Teasers" book:_ The `From` and `Into` traits are reciprocal, and if you provide one, Rust will automatically provide the other for you. (_e.g._ you define Fahrenheight-from-Celcius and Rust defines Celcius-into-Fahrenheit) Same with `TryFrom` and `TryInto`.

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

`Result` has lots of other methods like `or_else()`, `and_then()`, etc. that let you transform the result to fit the needed context. Another helpful one is that `result.map(...)` can be used to transform the `Ok()` case leaving the `Err()` intact. This comes in handy at the end of `FromStr` and other struct constructor functions:

```
widgets.iter()
    ...
    .collect::<Result<Vec<Gadget>>>()
    .map(|gadgets| Self { gadgets })
```

#### Simplifying `Result` With a Type

[This article](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/boxing_errors.html) shows how to add a type, such that you can replace `Result<..., ...>` with just `Result<...>` everywhere in your code. When the error portion of `Result` is `Box<dyn error::Error>` that cleans things up quite a bit.

Putting this at the top of each file (exactly as shown, using `T` generically) allows all functions to declare the return as simply `Result<Foo>`:

```
type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;
```

If the error you want to propagate isn't already boxed, you can return `Err(Box::new(e))` or (cleaner) `e.into()` to "box the error" (where `e` is a specific error like `io::Error` or a custom error type).

Standardizing this makes it easier to propagate errors up from multiple calls (see next section).

#### Propagating Results

Rust has the `?` operator which provides a concise way of propagating errors by returning them up the chain. In this example, in the `Ok` case, `?` will return the value to the `buf` assignment, and flow will continue to the next statement; in the `Err` case, `?` will cause `my_read_file()` to immediately return an error result to the caller:

```
fn my_read_file(file: &str) -> Result<String, io::Error> {
    let buf = fs::read(file)?;
    ...
}
```

If you're iterating over a collection _e.g._ with `.map()`, the closure can return a `Result<T, E>` and the `.collect()` will "roll up" the error and turn that into a `Result<Vec<T>, E>`. See the "Fail the entire operation with `collect()`" section of [this page](https://doc.rust-lang.org/rust-by-example/error/iter_result.html), which also has other options for handling errors when iterating.

If you supply a parsing function that returns `Result<T, E>`, the resulting rollup code can ba a tidy one line:

```
fn parse_branches(branches: &str) -> Result<Vec<Vec<usize>>> {
    branches.split(" | ").map(Rule::parse_sequence).collect()
}
```

However, note when parsing integers from strings, the code needs a bit of type hinting; `ParseIntError` isn't an `err::Error` so it has to be explicitly boxed with `.into()`. See [this page](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/boxing_errors.html) on boxing errors for details.

```
fn parse_sequence(sequence: &str) -> Result<Vec<usize>> {
    sequence.split(' ')
        .map(|rn| rn.parse::<usize>().map_err(|e| e.into()))
        .collect()
}
```

If the result needs to be unwrapped with propagation (using `?`), then `.collect()` needs a hint too:

```
fn from_str(line: &str) -> Result<Self> {
    let values: Vec<u32> = line.split(',')
        .map(|v| v.parse::<u32>().map_err(|e| e.into()))
        .collect::<Result<Vec<u32>>>()?;
    Ok(Self { values })
}
```

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

## Matching

The [`matches!()` macro](https://doc.rust-lang.org/std/macro.matches.html) "Returns whether the given expression matches any of the given patterns" so you can do things like:

```
let foo = 'f';
assert!(matches!(foo, 'A'..='Z' | 'a'..='z'));

let bar = Some(4);
assert!(matches!(bar, Some(x) if x > 2));
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

You can't use `const` with `Vec`, but you can do either:

- `const v: [i32; 5] = [1, 2, 3, 4, 5];`
- `static NUMBERS: &'static [i32] = &[1, 2, 3, 4, 5];`

Or use the `lazy_static!` macro (see above) and the code will be compiled in for efficiency.

Note also that you can't do heap allocations of constants yet.

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

        type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

        impl FromStr for MyStruct {
            type Err = Box<dyn std::error::Error>;
            fn from_str(line: &str) -> Result<Self> {
                // ...
            }
        }

Once this trait is defined, and generates its own errors (bad format, etc.), it becomes very easy to read a whole file, propagating any error to the caller:

        pub fn read_from_file(path: &str) -> Result<Vec<MyStruct>> {
            let s: String = fs::read_to_string(path)?;
            s.lines().map(str::parse).collect()
        }

Rust knows it's returning a vector of `MyStruct`, so it can push that type inwards to the `parse()` call to know what it needs. Collecting `Error` to the returned `Result` is described by the "Fail the entire operation with `collect()`" section of [this page](https://doc.rust-lang.org/rust-by-example/error/iter_result.html), which also has other options for handling errors when iterating.

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

### Useful String Functions

- `.starts_with(pat)` where `pat` can be a `&str`, `char`, slice, or "closure that determines if a character matches"

## Vectors

1. Rust always uses the `usize` type for indexing, so calls like `my_string.len()` return `usize`, and vectors expect to be indexed by a `usize`, etc.
1. One trick when needing to subtract from a `usize` is to use the `.wrapping_sub(i)` function:

```
    let i: usize = 0;
    // this returns `None` since 0 - 1 = usize::MAX
    let el = v[i.wrapping_sub(1)].get();
```

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

### Min, Max, Count

1. Rust provides `.min()` and `.max()` for an iterator; note that it returns `Option<&T>` for a vector, which means the result has to be unwrapped and dereferenced: `*values_vector.iter().min().unwrap()`
1. Rust also provides `.min_by()` and `.max_by()` which take a comparison function, useful for complex objects.
1. You can count matching elements using `things.iter().filter(|t| ...).count()` — but if speed is important, people say that `.fold()` is about 2x faster for this case.

### Other Helpful Iteration Methods

1. `try_fold()` calls a function that returns `Option`, and iterates until it sees a `None`.
1. `step_by(n)` lets you get every `n`th item and `skip(n)` lets you skip `n` items; between them you can _e.g._ iterate the odd and even ones.

### Ranges

In the range `(0..10)` the end value is not included (will go up to `9`). There is a notation to make it inclusive: `('a'..='z')` will go up to `'z'`.

### Itertools

The [itertools](https://crates.io/crates/itertools) crate has a lot of extra functionality for iterators, including:

- `.permutations()` and `.combinations()` which return another iterator that produces all permutations/combinations of the original
- `.tuple_permutations()` and `.tuple_combinations()` which return vectors rather than iterators
- `.tuple_windows(n)` which returns an iterator that produces tuples of n; _e.g._ with _2_ it will return `(1st_el, 2nd_el)`, then `(2nd_el, 3rd_el)`, etc. (this is similar to `Vec` `.windows(n)` which produces a new vector)
- `.unique()` to filter out duplicates (`Vec` has `.dedup()` but that's an in-place mutation)
- [`.multi_cartesian_product()`](https://docs.rs/itertools/0.6.0/itertools/macro.iproduct.html) can be used to replicate an iterator across multiple dimensions (for something like a 2D or 3D matrix); there is also an `iproduct!` macro

## Testing

1. Unit tests suppress `stdout`/`stderr` for any test that passes; you can use something like `assert!(false);` in a test to force it to fail and see any debugging output.

1. Use the `#[cfg(test)]` directive to mark functions that are only used for tests; this gets rid of "unused function" warnings when running the app. These functions will not appear in auto-generated documentation, so use `//` not `///` to document them.

1. Rust's test system will soon be able to perform [benchmarking measurements](https://doc.rust-lang.org/unstable-book/library-features/test.html) for testing performance. As of Dec 2020 (Rust v1.46.0) this is currently an "unstable" feature.
