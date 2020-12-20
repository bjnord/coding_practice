use std::fmt;
use std::fs;
use std::string;

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
    fn parse_rule(line: &str) -> Result<(usize, Rule)> {
        let tokens: Vec<&str> = line.split(": ").collect();
        let n: usize = tokens[0].parse()?;
        let content = tokens.get(1)
            .ok_or(RulesetError(String::from("no : separator found in rule")))?;
        if content.starts_with('"') {
            let ch = content.chars().nth(1)
                .ok_or(RulesetError(String::from("missing literal after quote in rule")))?;
            Ok((n, Rule::Literal(ch)))
        } else {
            Ok((n, Rule::Branches(Rule::parse_branches(content)?)))
        }
    }

    fn parse_branches(branches: &str) -> Result<Vec<Vec<usize>>> {
        branches.split(" | ").map(Rule::parse_sequence).collect()
    }

    fn parse_sequence(sequence: &str) -> Result<Vec<usize>> {
        sequence.split(' ')
            .map(|rn| rn.parse::<usize>().map_err(|e| e.into()))
            .collect()
    }
}

#[derive(Debug)]
pub struct Ruleset {
    rules: Vec<Rule>,
    messages: Vec<String>,
}

impl fmt::Display for Ruleset {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut s = String::new();
        for (i, rule) in self.rules.iter().enumerate() {
            if let Rule::None = rule { } else {
                s += &format!("{}: {}\n", i, rule);
            }
        }
        s += "\n";
        for message in &self.messages {
            s += &format!("{}\n", message);
        }
        write!(f, "{}", s)
    }
}

impl Ruleset {
    /// Returns number of rules.
    #[cfg(test)]
    #[must_use]
    pub fn n_rules(&self) -> usize {
        self.rules.iter().fold(0, |count, r| {
            if let Rule::None = r { count } else { count + 1 }
        })
    }

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
            let e = String::from("expected two sections separated by blank line");
            return Err(RulesetError(e).into());
        }
        let rules = Ruleset::rules_from_input(sections[0], part2)?;
        let messages = sections[1].lines()
            .map(string::ToString::to_string)
            .collect();
        Ok(Self { rules, messages })
    }

    /// Read rules from `input` (list of lines). If `part2` flag is set,
    /// rules 8 and 11 are altered as specified in the puzzle description.
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid rule format.
    pub fn rules_from_input(input: &str, part2: bool) -> Result<Vec<Rule>> {
        // `rules` is a sparse array, so we preallocate with empty slots
        let mut rules: Vec<Rule> = vec![Rule::None; MAX_RULES];
        for line in input.lines() {
            let (n, rule) = Rule::parse_rule(line)?;
            rules[n] = rule;
        }
        if part2 {
            rules[8] = Rule::Branches(vec![vec![42], vec![42, 8]]);
            rules[11] = Rule::Branches(vec![vec![42, 31], vec![42, 11, 31]]);
        }
        Ok(rules)
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
    //
    // Due to branching, each rule match can return **multiple** remainders.
    fn match_rule<'a>(&self, rule_n: usize, message: &'a str) -> Option<Vec<&'a str>> {
        match &self.rules[rule_n] {
            Rule::None => panic!("no rule found"),
            Rule::Literal(ch) => {
                match message.chars().next() {
                    Some(ch0) if ch0 == *ch => Some(vec![&message[1..]]),
                    _ => None,
                }
            },
            Rule::Branches(seqs) => {
                let remainders: Vec<&'a str> = seqs.iter()
                    .filter_map(|seq| self.match_sequence(message, &seq))
                    .flatten()
                    .collect();
                if remainders.is_empty() { None } else { Some(remainders) }
            },
        }
    }

    // Returns the remainders after matching the rules in a sequence, or
    // `None`.
    //
    // Due to branching, each rule match can return **multiple** remainders,
    // **each** of which needs to be tested against the next rule in the
    // sequence. So we replace `remainders` at each step; if a rule returns
    // no remainders, the sequence cannot be matched and we return `None`.
    fn match_sequence<'a>(&self, message: &'a str, seq: &[usize]) -> Option<Vec<&'a str>> {
        let mut remainders = vec![&message[..]];
        for rule_n in seq {
            let new_remainders: Vec<&'a str> = remainders.iter()
                .filter_map(|rem| self.match_rule(*rule_n, rem))
                .flatten()
                .collect();
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
        assert_eq!(4, ruleset.n_rules());
        assert_eq!(4, ruleset.messages.len());
    }

    #[test]
    fn test_read_from_file_2() {
        let ruleset = Ruleset::read_from_file("input/example2.txt", false).unwrap();
        assert_eq!(6, ruleset.n_rules());
        assert_eq!(5, ruleset.messages.len());
        assert_eq!(Rule::Branches(vec![vec![4, 1, 5]]), ruleset.rules[0]);
        assert_eq!(Rule::Branches(vec![vec![4, 5], vec![5, 4]]), ruleset.rules[3]);
        assert_eq!(Rule::Literal('b'), ruleset.rules[5]);
    }

    #[test]
    fn test_read_from_file_3_part1_rules() {
        let ruleset = Ruleset::read_from_file("input/example3.txt", false).unwrap();
        assert_eq!(31, ruleset.n_rules());
        assert_eq!(Rule::Branches(vec![vec![42]]), ruleset.rules[8]);
        assert_eq!(Rule::Branches(vec![vec![42, 31]]), ruleset.rules[11]);
    }

    #[test]
    fn test_read_from_file_3_part2_rules() {
        let ruleset = Ruleset::read_from_file("input/example3.txt", true).unwrap();
        assert_eq!(31, ruleset.n_rules());
        assert_eq!(Rule::Branches(vec![vec![42], vec![42, 8]]), ruleset.rules[8]);
        assert_eq!(Rule::Branches(vec![vec![42, 31], vec![42, 11, 31]]), ruleset.rules[11]);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let ruleset = Ruleset::read_from_file("input/example99.txt", false);
        assert!(ruleset.is_err());
    }

    #[test]
    fn test_read_from_file_bad_sequence() {
        let result = Ruleset::read_from_file("input/bad1.txt", false);
        assert!(result.is_err());
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

    #[test]
    fn test_rules_from_input_no_colon() {
        let result = Ruleset::rules_from_input("0", false);
        assert!(result.is_err());
    }

    #[test]
    fn test_rules_from_input_bad_literal() {
        let result = Ruleset::rules_from_input("1: \"", false);
        assert!(result.is_err());
    }
}
