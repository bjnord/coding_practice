use std::fmt;
use std::fs;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

const MAX_RULES: usize = 200;

#[derive(Debug, Clone)]
struct RulesetError(String);

impl fmt::Display for RulesetError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Ruleset error: {}", self.0)
    }
}

impl std::error::Error for RulesetError {}

#[derive(Debug, Clone, Eq, PartialEq)]
pub enum Rule {
    None,
    Literal(char),
    Branches(Vec<Vec<usize>>),
}

impl fmt::Display for Rule {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Rule::None => write!(f, "_0_"),
            Rule::Literal(ch) => write!(f, "\"{}\"", ch),
            Rule::Branches(bb) => {
                let ss: Vec<String> = bb
                    .iter()
                    .map(|b| format!("{:?}", b))
                    .collect();
                write!(f, "{}", ss.join(" | "))
            },
        }
    }
}

impl Rule {
    /// Read rules from `input` (list of lines). If `part2` flag is set,
    /// rules 8 and 11 are altered as specified in the puzzle description.
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid rule format.
    pub fn from_input(input: &str, part2: bool) -> Result<(usize, Vec<Rule>)> {
        let mut max_n: usize = 0;
        let mut rules: Vec<Rule> = vec![Rule::None; MAX_RULES];
        for line in input.lines() {
            let tokens: Vec<&str> = line.split(": ").collect();
            let n: usize = tokens[0].parse()?;
            if n > max_n {
                max_n = n;
            }
            if tokens[1].contains("\"") {
                let ch = tokens[1].chars().nth(1).unwrap();
                rules[n] = Rule::Literal(ch);
            } else {
                rules[n] = Rule::Branches(Rule::parse_branches(tokens[1])?);
            }
        }
        if part2 {
            rules[8] = Rule::Branches(vec![vec![42], vec![42, 8]]);
            rules[11] = Rule::Branches(vec![vec![42, 31], vec![42, 11, 31]]);
        }
        Ok((max_n + 1, rules))
    }

    fn parse_branches(branches: &str) -> Result<Vec<Vec<usize>>> {
        branches.split(" | ")
            .map(|seq| Rule::parse_sequence(seq))
            .collect()
    }

    // FIXME for some reason this collect() won't roll up a ParseIntError
    //       from parse() into a Box; had to short-circuit with unwrap()
    fn parse_sequence(sequence: &str) -> Result<Vec<usize>> {
        let rule_nos: Vec<usize> = sequence.split(' ')
            .map(|rn| rn.parse().unwrap())
            .collect();
        Ok(rule_nos)
    }
}

#[derive(Debug)]
pub struct Ruleset {
    rules: Vec<Rule>,
    n_rules: usize,
    messages: Vec<String>,
}

impl fmt::Display for Ruleset {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for (i, rule) in self.rules.iter().enumerate() {
            if i >= self.n_rules {
                break;
            }
            s += &format!("{}: {}\n", i, rule);
        }
        s += "\n";
        for message in self.messages.iter() {
            s += &format!("{}\n", message);
        }
        write!(f, "{}", s)
    }
}

impl Ruleset {
    /// Construct by reading rules and messages from file at `path`. If
    /// `part2` flag is set, rules 8 and 11 are altered as specified in
    /// the puzzle description.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str, part2: bool) -> Result<Ruleset> {
        let s: String = fs::read_to_string(path)?;
        let sections: Vec<&str> = s.split("\n\n").collect();
        if sections.len() < 2 {
            let e = format!("expected two sections separated by blank line");
            return Err(RulesetError(e).into());
        }
        let (n_rules, rules) = Rule::from_input(sections[0], part2)?;
        let messages = sections[1].lines().map(|s| s.to_string()).collect();
        Ok(Self { rules, n_rules, messages })
    }

    /// How many messages match the rules?
    #[must_use]
    pub fn match_count(&self) -> usize {
        self.messages
            .iter()
            .filter(|m| self.matches(m))
            .count()
    }

    /// Does the given `message` match the rules?
    #[must_use]
    pub fn matches(&self, message: &str) -> bool {
        match self.match_rule(0, message) {
            Some(remainders) => {
                remainders.iter().any(|&r| r == "")
            },
            None => false,
        }
    }

    // Returns the remainders after matching a rule, or `None`.
    fn match_rule<'a>(&self, rule_n: usize, message: &'a str) -> Option<Vec<&'a str>> {
        match &self.rules[rule_n] {
            Rule::None => panic!("no rule found"),
            Rule::Literal(ch) => {
                let first = message.chars().nth(0);
                if first.is_some() && first.unwrap() == *ch {
                    Some(vec![&message[1..]])
                } else {
                    None
                }
            },
            Rule::Branches(seqs) => {
                let mut remainders = vec![];
                for seq in seqs {
                    if let Some(rems) = self.match_sequence(message, &seq) {
                        remainders.extend(rems);
                    }
                }
                // FIXME uniqify
                if remainders.is_empty() { None } else { Some(remainders) }
            },
        }
    }

    // Returns the remainders after matching one or more rules in a
    // sequence, or `None`.
    fn match_sequence<'a>(&self, message: &'a str, seq: &Vec<usize>) -> Option<Vec<&'a str>> {
        let mut remainders = vec![&message[..]];
        for rule_n in seq {
            let mut new_remainders = vec![];
            for rem in remainders {
                if let Some(rems) = self.match_rule(*rule_n, rem) {
                    new_remainders.extend(rems);
                }
            }
            if new_remainders.is_empty() {
                return None;
            }
            remainders = new_remainders;
        }
        Some(remainders)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file_1() {
        let ruleset = Ruleset::read_from_file("input/example1.txt", false).unwrap();
        assert_eq!(4, ruleset.n_rules);
        assert_eq!(4, ruleset.messages.len());
    }

    #[test]
    fn test_read_from_file_2() {
        let ruleset = Ruleset::read_from_file("input/example2.txt", false).unwrap();
        assert_eq!(6, ruleset.n_rules);
        assert_eq!(5, ruleset.messages.len());
        assert_eq!(Rule::Branches(vec![vec![4, 1, 5]]), ruleset.rules[0]);
        assert_eq!(Rule::Branches(vec![vec![4, 5], vec![5, 4]]), ruleset.rules[3]);
        assert_eq!(Rule::Literal('b'), ruleset.rules[5]);
    }

    #[test]
    fn test_read_from_file_3_part1_rules() {
        let ruleset = Ruleset::read_from_file("input/example3.txt", false).unwrap();
        assert_eq!(43, ruleset.n_rules);
        assert_eq!(Rule::Branches(vec![vec![42]]), ruleset.rules[8]);
        assert_eq!(Rule::Branches(vec![vec![42, 31]]), ruleset.rules[11]);
    }

    #[test]
    fn test_read_from_file_3_part2_rules() {
        let ruleset = Ruleset::read_from_file("input/example3.txt", true).unwrap();
        assert_eq!(43, ruleset.n_rules);
        assert_eq!(Rule::Branches(vec![vec![42], vec![42, 8]]), ruleset.rules[8]);
        assert_eq!(Rule::Branches(vec![vec![42, 31], vec![42, 11, 31]]), ruleset.rules[11]);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let ruleset = Ruleset::read_from_file("input/example99.txt", false);
        assert!(ruleset.is_err());
    }

    #[test]
    // see from_input() FIXME above
    #[should_panic]
    fn test_read_from_file_bad_sequence() {
        let _result = Ruleset::read_from_file("input/bad1.txt", false);
    }

    #[test]
    fn test_read_from_file_no_sections() {
        let result = Ruleset::read_from_file("input/bad2.txt", false);
        assert!(result.is_err());
    }

    #[test]
    fn test_match_count_1() {
        let ruleset = Ruleset::read_from_file("input/example1.txt", false).unwrap();
        assert_eq!(2, ruleset.match_count());
    }

    #[test]
    fn test_match_count_2() {
        let ruleset = Ruleset::read_from_file("input/example2.txt", false).unwrap();
        assert_eq!(2, ruleset.match_count());
    }

    #[test]
    fn test_match_count_3_part1_rules() {
        let ruleset = Ruleset::read_from_file("input/example3.txt", false).unwrap();
        assert_eq!(3, ruleset.match_count());
    }

    #[test]
    fn test_match_count_3_part2_rules() {
        let ruleset = Ruleset::read_from_file("input/example3.txt", true).unwrap();
        assert_eq!(12, ruleset.match_count());
    }
}
