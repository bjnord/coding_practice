pub mod readln {
    use std::io::{self, Write};

    pub fn read_i32(prompt: &str) -> Result<i32, io::Error> {
        loop {
            print_prompt(prompt)?;
            let resp = read_response()?;
            match resp.parse::<i32>() {
                Ok(n) => return Ok(n),
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_i32_range(prompt: &str, min: i32, max: i32) -> Result<i32, io::Error> {
        loop {
            print_prompt(prompt)?;
            let resp = read_response()?;
            match resp.parse::<i32>() {
                Ok(n) => {
                    if n >= min && n <= max {
                        return Ok(n);
                    } else {
                        println!("Number must be between {} and {}.", min, max);
                    }
                },
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_u32(prompt: &str) -> Result<u32, io::Error> {
        loop {
            print_prompt(prompt)?;
            let resp = read_response()?;
            match resp.parse::<u32>() {
                Ok(n) => return Ok(n),
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_f64(prompt: &str) -> Result<f64, io::Error> {
        loop {
            print_prompt(prompt)?;
            let resp = read_response()?;
            match resp.parse::<f64>() {
                Ok(n) => return Ok(n),
                Err(e) => println!("That is not a valid number: {}", e)
            }
        }
    }

    pub fn read_string(prompt: &str) -> Result<String, io::Error> {
        print_prompt(prompt)?;
        let resp = read_response()?;
        Ok(resp)
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
