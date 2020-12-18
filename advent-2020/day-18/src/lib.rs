use std::fmt;
use std::fs;
use std::result;
use std::str::FromStr;

type Result<T> = result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone)]
struct EquationError(String);

impl fmt::Display for EquationError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Equation error: {}", self.0)
    }
}

impl std::error::Error for EquationError {}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum Term {
    Number(i32),
    Operator(char),
}

impl FromStr for Term {
    type Err = Box<dyn std::error::Error>;

    fn from_str(token: &str) -> Result<Self> {
        let ch = token.chars().next().ok_or("empty term")?;
        let term = match ch {
            '+' => Term::Operator('+'),
            '*' => Term::Operator('*'),
            _ => Term::Number(token.parse::<i32>()?),
        };
        Ok(term)
    }
}

impl fmt::Display for Term {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Term::Number(n) => write!(f, "{}", n),
            Term::Operator(ch) => write!(f, "{}", ch),
        }
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Equation {
    terms: Vec<Term>,
}

impl FromStr for Equation {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let terms: Result<Vec<Term>> = line
            .split(' ')
            .map(str::parse)
            .collect();
        match terms {
            Err(e) => Err(e),
            Ok(t) => Ok(Self { terms: t }),
        }
    }
}

impl fmt::Display for Equation {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for (i, term) in self.terms.iter().enumerate() {
            if i > 0 {
                s += " ";
            }
            s += &format!("{}", term);
        }
        write!(f, "{}", s)
    }
}

impl Equation {
    /// Return list of equation terms.
    #[cfg(test)]
    #[must_use]
    pub fn terms(&self) -> &Vec<Term> {
        &self.terms
    }

    /// Construct by reading equations from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if an invalid
    /// equation is found.
    pub fn read_from_file(path: &str) -> Result<Vec<Equation>> {
        let s: String = fs::read_to_string(path)?;
        s.lines().map(str::parse).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // 1 + 2 * 3 + 4 * 5 + 6 becomes 71.

    // 2 * 3 + (4 * 5) becomes 26.
    // 5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 437.
    // 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 12240.
    // ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 13632.

    #[test]
    fn test_parse_equations_simple() {
        let equations = Equation::read_from_file("input/example1.txt").unwrap();
        assert_eq!(1, equations.len());
        assert_eq!(11, equations[0].terms().len());
    }

    #[test]
    fn test_parse_equation_bad_term() {
        let result = "1 + X".parse::<Equation>();
        assert!(result.is_err());
    }

    #[test]
    fn test_parse_equation_double_space() {
        let result = "1  + 2".parse::<Equation>();
        assert!(result.is_err());
    }
}
