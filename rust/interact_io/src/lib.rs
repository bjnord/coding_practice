pub mod readln {
    use std::io::{self, Write};

    pub fn read_i32(prompt: &str) -> i32 {
        loop {
            print_prompt(prompt).unwrap();
            let resp = read_response().unwrap();
            match resp.parse::<i32>() {
                Ok(n) => break n,
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_i32_range(prompt: &str, min: i32, max: i32) -> i32 {
        loop {
            print_prompt(prompt).unwrap();
            let resp = read_response().unwrap();
            match resp.parse::<i32>() {
                Ok(n) => {
                    if n >= min && n <= max {
                        break n;
                    } else {
                        println!("Number must be between {} and {}.", min, max);
                    }
                },
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_u32(prompt: &str) -> u32 {
        loop {
            print_prompt(prompt).unwrap();
            let resp = read_response().unwrap();
            match resp.parse::<u32>() {
                Ok(n) => break n,
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_f64(prompt: &str) -> f64 {
        loop {
            print_prompt(prompt).unwrap();
            let resp = read_response().unwrap();
            match resp.parse::<f64>() {
                Ok(n) => break n,
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_string(prompt: &str) -> String {
        print_prompt(prompt).unwrap();
        read_response().unwrap()
    }

    // private
    fn print_prompt(prompt: &str) -> Result<(), io::Error> {
        print!("{}", prompt);
        io::stdout().flush()
    }

    // private
    fn read_response() -> Result<String, io::Error> {
        let mut response = String::new();
        io::stdin().read_line(&mut response)?;
        Ok(String::from(response.trim()))
    }
}
