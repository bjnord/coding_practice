use crate::equation::{Equation, EquationError};
use std::fmt;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone, Eq, PartialEq)]
pub enum Term {
    Number(i64),
    Operator(char),
    Subterm(Equation),
}

impl FromStr for Term {
    type Err = Box<dyn std::error::Error>;

    fn from_str(token: &str) -> Result<Self> {
        let ch = token
            .chars()
            .next()
            .ok_or_else(|| EquationError::EmptyTerm)?;
        let term = match ch {
            d if d.is_digit(10) => Term::Number(token.parse::<i64>()?),
            '(' => {
                let eq = &token[1..token.len()-1];
                Term::Subterm(eq.parse::<Equation>()?)
            },
            _ => Term::Operator(ch),
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
    ///
    /// # Examples
    ///
    /// ```
    /// # use day_18::term::Term;
    /// let tokens: Vec<&str> = vec!["((2", "+", "3)", "*", "5)", "*", "(7", "+", "11)"];
    /// let combined_tokens = Term::combine_subterm_tokens(&tokens).unwrap();
    /// assert_eq!(vec!["((2 + 3) * 5)", "*", "(7 + 11)"], combined_tokens);
    /// ```
    ///
    /// # Errors
    ///
    /// Returns `Err` if the list of terms is invalid (_e.g._ too many
    /// right parentheses).
    #[allow(clippy::ptr_arg)]  // &[&str] doesn't work here
    pub fn combine_subterm_tokens(tokens: &Vec<&str>) -> Result<Vec<String>> {
        let mut combined_tokens: Vec<String> = vec![];
        let mut subterm = String::new();
        let mut p_count = 0_usize;
        for token in tokens {
            p_count = Term::adjusted_paren_count(p_count, token)?;
            if !subterm.is_empty() {
                subterm += " ";
            }
            subterm += token;
            if p_count == 0 {
                combined_tokens.push(subterm);
                subterm = String::new();
            }
        }
        Ok(combined_tokens)
    }

    fn adjusted_paren_count(count: usize, token: &str) -> Result<usize> {
        let lp = token.matches('(').count();
        let rp = token.matches(')').count();
        if rp > count + lp {
            return Err(EquationError::Parentheses { lp, count, rp }.into());
        }
        Ok(count + lp - rp)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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
    fn test_combine_subterm_tokens_simple() {
        let tokens = vec!["1", "*", "2", "+", "3", "*", "4"];
        let combined_tokens = Term::combine_subterm_tokens(&tokens).unwrap();
        let actual: Vec<&str> = combined_tokens.iter().map(|s| &s[..]).collect();
        assert_eq!(tokens, actual);
    }

    #[test]
    fn test_combine_subterm_tokens_one_level() {
        let tokens = vec!["1", "*", "(2", "+", "3)", "*", "4"];
        let expected = vec!["1", "*", "(2 + 3)", "*", "4"];
        let combined_tokens = Term::combine_subterm_tokens(&tokens).unwrap();
        let actual: Vec<&str> = combined_tokens.iter().map(|s| &s[..]).collect();
        assert_eq!(expected, actual);
    }

    #[test]
    fn test_combine_subterm_tokens_two_levels_front() {
        let tokens = vec!["1", "*", "((2", "+", "3)", "*", "5)", "*", "4"];
        let expected = vec!["1", "*", "((2 + 3) * 5)", "*", "4"];
        let combined_tokens = Term::combine_subterm_tokens(&tokens).unwrap();
        let actual: Vec<&str> = combined_tokens.iter().map(|s| &s[..]).collect();
        assert_eq!(expected, actual);
    }

    #[test]
    fn test_combine_subterm_tokens_extra_rparens() {
        let tokens = vec!["1", "*", "(2", "+", "3))"];
        match Term::combine_subterm_tokens(&tokens) {
            Err(e) => assert_eq!("right-parens=2 exceeds paren-count=1 + left-parens=0", e.to_string()),
            Ok(_) => panic!("test did not fail"),
        }
    }

    #[test]
    fn test_parse_term_empty() {
        match "".parse::<Term>() {
            Err(e) => assert_eq!("empty term", e.to_string()),
            Ok(_) => panic!("test did not fail"),
        }
    }
}
