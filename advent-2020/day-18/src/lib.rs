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

#[derive(Debug, Clone, Eq, PartialEq)]
pub enum Term {
    Number(i64),
    Operator(char),
    Subterm(Equation),
}

impl FromStr for Term {
    type Err = Box<dyn std::error::Error>;

    fn from_str(token: &str) -> Result<Self> {
        let ch = token.chars().next().ok_or("empty term")?;
        let term = match ch {
            d if d.is_digit(10) => Term::Number(token.parse::<i64>()?),
            '('                 => {
                let eq = &token[1..token.len()-1];
                Term::Subterm(eq.parse::<Equation>()?)
            },
            _                   => Term::Operator(ch),
        };
        Ok(term)
    }
}

impl fmt::Display for Term {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Term::Number(n) => write!(f, "{}", n),
            Term::Operator(op) => write!(f, "{}", op),
            Term::Subterm(eq) => {
                let s = format!("({})", eq);
                write!(f, "{}", s)
            },
        }
    }
}

impl Term {
    /// Combine tokens to form subterms.
    pub fn combine_subterms(tokens: &Vec<&str>) -> Vec<String> {
        let mut ctokens: Vec<String> = vec![];
        let mut subterm = String::new();
        let mut pcount = 0_usize;
        for token in tokens {
            let lp = token.matches("(").count();
            let rp = token.matches(")").count();
            if lp == 0 && rp == 0 && pcount == 0 {
                ctokens.push(token.to_string());
                continue;
            }
            if rp > pcount + lp {
                // FIXME `combine_subterms()` should return a `Result`
                panic!("rp={} exceeds pcount={} lp={}", rp, pcount, lp);
            }
            if !subterm.is_empty() {
                subterm += " ";
            }
            subterm += token;
            pcount = pcount + lp - rp;
            if pcount == 0 {
                ctokens.push(subterm);
                subterm = String::new();
            }
        }
        ctokens
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Equation {
    terms: Vec<Term>,
}

impl FromStr for Equation {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let tokens = line.split(' ').collect();
        let ctokens = Term::combine_subterms(&tokens);
        let terms: Result<Vec<Term>> = ctokens
            .iter()
            .map(|s| &s[..])
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

    /// Solve equation.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the equation terms do not form a valid equation.
    pub fn solve(&self) -> Result<i64> {
        let mut buffer: Vec<Term> = vec![];
        for term in &self.terms {
            buffer.push(match term {
                Term::Number(n) => Term::Number(*n),
                Term::Operator(op) => Term::Operator(*op),
                Term::Subterm(eq) => {
                    let n: i64 = eq.solve()?;
                    Term::Number(n)
                },
            });
            if buffer.len() == 3 {
                buffer = Equation::combine_3(buffer)?;
            }
        }
        if buffer.len() > 1 {
            let e = format!("{} leftover term(s)", buffer.len() - 1);
            return Err(EquationError(e).into());
        }
        if let Term::Number(n) = buffer[0] {
            Ok(n)
        } else {
            Err(EquationError("final term is not a Number".to_string()).into())
        }
    }

    fn combine_3(terms: Vec<Term>) -> Result<Vec<Term>> {
        let combined_term = match &terms[0..3] {
            [Term::Number(n1), Term::Operator(op), Term::Number(n2)] => {
                match op {
                    '+' => Term::Number(n1 + n2),
                    '*' => Term::Number(n1 * n2),
                    _ => {
                        let e = format!("invalid operator '{}'", op);
                        return Err(EquationError(e).into());
                    },
                }
            },
            _ => {
                let e = format!("invalid expression '{} {} {}'", terms[0], terms[1], terms[2]);
                return Err(EquationError(e).into());
            },
        };
        Ok(vec![combined_term])
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // 1 + 2 * 3 + 4 * 5 + 6 becomes 71.

    #[test]
    fn test_parse_equations_simple() {
        let equations = Equation::read_from_file("input/example1.txt").unwrap();
        assert_eq!(1, equations.len());
        assert_eq!(11, equations[0].terms().len());
    }

    #[test]
    fn test_solve_equations_simple() {
        let equations = Equation::read_from_file("input/example1.txt").unwrap();
        assert_eq!(1, equations.len());
        assert_eq!(71, equations[0].solve().unwrap());
    }

    // 2 * 3 + (4 * 5) becomes 26.
    // 5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 437.
    // 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 12240.
    // ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 13632.

    #[test]
    fn test_parse_equations_with_subterms() {
        let equations = Equation::read_from_file("input/example2.txt").unwrap();
        assert_eq!(4, equations.len());
        assert_eq!(5, equations[0].terms().len());
        assert_eq!(3, equations[1].terms().len());
        assert_eq!(5, equations[2].terms().len());
        assert_eq!(7, equations[3].terms().len());
    }

    #[test]
    fn test_solve_equations_with_subterms() {
        let equations = Equation::read_from_file("input/example2.txt").unwrap();
        assert_eq!(4, equations.len());
        assert_eq!(26, equations[0].solve().unwrap());
        assert_eq!(437, equations[1].solve().unwrap());
        assert_eq!(12240, equations[2].solve().unwrap());
        assert_eq!(13632, equations[3].solve().unwrap());
    }

    #[test]
    fn test_parse_equation_bad_term() {
        let result = "1 + 2x".parse::<Equation>();
        assert!(result.is_err());
    }

    #[test]
    fn test_parse_equation_double_space() {
        let result = "1  + 2".parse::<Equation>();
        assert!(result.is_err());
    }

    #[test]
    fn test_parse_equation_subterm() {
        let term = "(2 + 3)".parse::<Term>().unwrap();
        let equation = match term {
            Term::Subterm(e) => e,
            _ => panic!("not a subterm"),
        };
        assert_eq!(3, equation.terms().len());
        assert_eq!(equation.terms()[0], Term::Number(2));
        assert_eq!(equation.terms()[1], Term::Operator('+'));
        assert_eq!(equation.terms()[2], Term::Number(3));
    }

    #[test]
    fn test_parse_equation_subterm_two_level() {
        let term = "((2 + 3) * 5)".parse::<Term>().unwrap();
        let equation = match term {
            Term::Subterm(e) => e,
            _ => panic!("not a subterm"),
        };
        assert_eq!(3, equation.terms().len());
        assert_eq!(equation.terms()[1], Term::Operator('*'));
        assert_eq!(equation.terms()[2], Term::Number(5));
        let subeq = match &equation.terms()[0] {
            Term::Subterm(eq) => eq,
            _ => panic!("expected subequation not found"),
        };
        assert_eq!(3, subeq.terms().len());
        assert_eq!(subeq.terms()[0], Term::Number(2));
        assert_eq!(subeq.terms()[1], Term::Operator('+'));
        assert_eq!(subeq.terms()[2], Term::Number(3));
    }

    #[test]
    fn test_solve_equation_invalid_operator() {
        let result = "1 + 2 / 3".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_solve_equation_missing_operator() {
        let result = "1 + 2 3".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_solve_equation_missing_operator_subterm() {
        let result = "1 + 2 (3 + 5)".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_solve_equation_double_operator() {
        let result = "1 * + 2".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_solve_equation_lone_operator() {
        let result = "+".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_solve_equation_missing_first_number() {
        let result = "+ 2".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_solve_equation_trailing_operator() {
        let result = "1 *".parse::<Equation>().unwrap().solve();
        assert!(result.is_err());
    }

    #[test]
    fn test_combine_subterms_simple() {
        let tokens = vec!["1", "*", "2", "+", "3", "*", "4"];
        let ctokens = Term::combine_subterms(&tokens);
        let actual: Vec<&str> = ctokens.iter().map(|s| &s[..]).collect();
        assert_eq!(tokens, actual);
    }

    #[test]
    fn test_combine_subterms_one_level() {
        let tokens = vec!["1", "*", "(2", "+", "3)", "*", "4"];
        let expected = vec!["1", "*", "(2 + 3)", "*", "4"];
        let ctokens = Term::combine_subterms(&tokens);
        let actual: Vec<&str> = ctokens.iter().map(|s| &s[..]).collect();
        assert_eq!(expected, actual);
    }

    #[test]
    fn test_combine_subterms_two_levels_front() {
        let tokens = vec!["1", "*", "((2", "+", "3)", "*", "5)", "*", "4"];
        let expected = vec!["1", "*", "((2 + 3) * 5)", "*", "4"];
        let ctokens = Term::combine_subterms(&tokens);
        let actual: Vec<&str> = ctokens.iter().map(|s| &s[..]).collect();
        assert_eq!(expected, actual);
    }

    #[test]
    #[should_panic]
    fn test_combine_subterms_extra_rparens() {
        let tokens = vec!["1", "*", "(2", "+", "3))"];
        Term::combine_subterms(&tokens);
    }
}
