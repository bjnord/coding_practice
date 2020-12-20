use crate::term::Term;
use std::fmt;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Debug, Clone)]
#[allow(clippy::module_name_repetitions)]
pub struct EquationError(pub String);

impl fmt::Display for EquationError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Equation error: {}", self.0)
    }
}

impl std::error::Error for EquationError {}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Equation {
    terms: Vec<Term>,
}

impl FromStr for Equation {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let tokens = line.split(' ').collect();
        let combined_tokens = Term::combine_subterm_tokens(&tokens)?;
        combined_tokens
            .iter()
            .map(|s| &s[..])
            .map(str::parse)
            .collect::<Result<Vec<Term>>>()
            .map(|terms| Self { terms })
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

    /// Solve equation with `+` having higher precedence than `*`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the equation terms do not form a valid equation.
    pub fn solve_advanced_math(&self) -> Result<i64> {
        let solver = |eq: &Equation| eq.solve_advanced_math();
        let mut terms: Vec<Term> = Equation::solve_subterms(&self.terms, solver)?;
        // solve all the N + M, leaving only multiply operators
        while terms.len() >= 3 {
            let add_pos = terms
                .iter()
                .position(|t| match t {
                    Term::Operator(op) => *op == '+',
                    _ => false,
                });
            if let Some(i) = add_pos {
                terms.splice(i-1..i+2, Equation::combine_3_terms_at(&terms, i-1)?);
            } else {
                break;  // no more add operators
            }
        }
        // solve the remaining terms (all multiply operators)
        while terms.len() >= 3 {
            terms.splice(..3, Equation::combine_3_terms_at(&terms, 0)?);
        }
        Equation::answer(&terms)
    }

    /// Solve equation left-to-right (with equal precedence of `+` and `*`).
    ///
    /// # Errors
    ///
    /// Returns `Err` if the equation terms do not form a valid equation.
    pub fn solve(&self) -> Result<i64> {
        let solver = |eq: &Equation| eq.solve();
        let mut terms: Vec<Term> = Equation::solve_subterms(&self.terms, solver)?;
        while terms.len() >= 3 {
            terms.splice(..3, Equation::combine_3_terms_at(&terms, 0)?);
        }
        Equation::answer(&terms)
    }

    // Solve all subterms in this list of terms (parenthesized subterms are
    // always highest-precedence). Returns a new list of terms, containing
    // only numbers and operators.
    fn solve_subterms<F>(terms: &[Term], solver: F) -> Result<Vec<Term>>
        where F: Fn(&Equation) -> Result<i64>
    {
        terms.iter()
            .map(|term| match term {
                Term::Number(n) => Ok(Term::Number(*n)),
                Term::Operator(op) => Ok(Term::Operator(*op)),
                Term::Subterm(eq) => {
                    let n: i64 = solver(&eq)?;
                    Ok(Term::Number(n))
                },
            })
            .collect()
    }

    // Return a new term list, which replaces the three `terms` at `i`
    // (number, operator, number) with the solution to that operation
    // (a number term).
    #[allow(clippy::single_match_else)]  // too big for one line here
    fn combine_3_terms_at(terms: &[Term], i: usize) -> Result<Vec<Term>> {
        let combined_term = match &terms[i..i+3] {
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

    // Convert lone remaining term to concrete integer.
    fn answer(terms: &[Term]) -> Result<i64> {
        if terms.len() > 1 {
            let e = format!("{} leftover term(s)", terms.len() - 1);
            return Err(EquationError(e).into());
        }
        if let Term::Number(n) = terms[0] {
            Ok(n)
        } else {
            Err(EquationError("final term is not a Number".to_string()).into())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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

    #[test]
    fn test_parse_equations_with_subterms() {
        let equations = Equation::read_from_file("input/example2.txt").unwrap();
        assert_eq!(5, equations.len());
        assert_eq!(5, equations[0].terms().len());
        assert_eq!(5, equations[1].terms().len());
        assert_eq!(3, equations[2].terms().len());
        assert_eq!(5, equations[3].terms().len());
        assert_eq!(7, equations[4].terms().len());
    }

    #[test]
    fn test_solve_equations_with_subterms() {
        let equations = Equation::read_from_file("input/example2.txt").unwrap();
        assert_eq!(5, equations.len());
        assert_eq!(51, equations[0].solve().unwrap());
        assert_eq!(26, equations[1].solve().unwrap());
        assert_eq!(437, equations[2].solve().unwrap());
        assert_eq!(12240, equations[3].solve().unwrap());
        assert_eq!(13632, equations[4].solve().unwrap());
    }

    #[test]
    fn test_solve_advanced_equations_with_subterms() {
        let equations = Equation::read_from_file("input/example2.txt").unwrap();
        assert_eq!(5, equations.len());
        assert_eq!(51, equations[0].solve_advanced_math().unwrap());
        assert_eq!(46, equations[1].solve_advanced_math().unwrap());
        assert_eq!(1445, equations[2].solve_advanced_math().unwrap());
        assert_eq!(669060, equations[3].solve_advanced_math().unwrap());
        assert_eq!(23340, equations[4].solve_advanced_math().unwrap());
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
}
