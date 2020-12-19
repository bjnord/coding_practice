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

// TODO RF: combine Sequence and Branch to Branch(Vec<Vec<usize>>)
//      (Sequence just has one branch; Branch has two in our puzzle input)
//      and replace MatchNode left and right with "branches" Vec
#[derive(Debug, Clone, Eq, PartialEq)]
pub enum Rule {
    None,
    Literal(char),
    Sequence(Vec<usize>),
    Branch(Vec<usize>, Vec<usize>),
}

impl fmt::Display for Rule {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Rule::None => write!(f, "_0_"),
            Rule::Literal(ch) => write!(f, "\"{}\"", ch),
            Rule::Sequence(s) => write!(f, "{:?}", s),
            Rule::Branch(s1, s2) => write!(f, "{:?} | {:?}", s1, s2),
        }
    }
}

impl Rule {
    /// Read rules from `input` (list of lines).
    ///
    /// # Errors
    ///
    /// Returns `Err` if a line is found with an invalid rule format.
    pub fn from_input(input: &str) -> Result<(usize, Vec<Rule>)> {
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
                continue;
            }
            if tokens[1].contains("|") {
                let seqs: Vec<&str> = tokens[1].split(" | ").collect();
                rules[n] = Rule::Branch(Rule::parse_seq(seqs[0])?,
                    Rule::parse_seq(seqs[1])?);
                continue;
            }
            rules[n] = Rule::Sequence(Rule::parse_seq(tokens[1])?);
        }
        Ok((max_n + 1, rules))
    }

    // FIXME for some reason this collect() won't roll up a ParseIntError
    //       from parse() into a Box; had to short-circuit with unwrap()
    fn parse_seq(seq: &str) -> Result<Vec<usize>> {
        let rule_nos: Vec<usize> = seq.split(' ')
            .map(|s| s.parse().unwrap())
            .collect();
        Ok(rule_nos)
    }
}

#[derive(Debug)]
pub struct MatchNode {
    rule: Rule,
    left: Vec<MatchNode>,
    right: Vec<MatchNode>,
}

impl MatchNode {
    pub fn from_rule(rule: &Rule, rules: &Vec<Rule>) -> MatchNode {
        match rule {
            Rule::None => panic!("no rule found"),
            Rule::Literal(_) => {
                MatchNode { rule: rule.clone(), left: vec![], right: vec![] }
            },
            Rule::Sequence(seq) => {
                let left = seq.iter()
                    .map(|n| MatchNode::from_rule(&rules[*n], rules))
                    .collect();
                MatchNode { rule: rule.clone(), left, right: vec![] }
            },
            Rule::Branch(seq_l, seq_r) => {
                let left = seq_l.iter()
                    .map(|n| MatchNode::from_rule(&rules[*n], rules))
                    .collect();
                let right = seq_r.iter()
                    .map(|n| MatchNode::from_rule(&rules[*n], rules))
                    .collect();
                MatchNode { rule: rule.clone(), left, right }
            },
        }
    }

    /// Does the given `message` match the rules?
    #[must_use]
    pub fn matches(&self, message: &str) -> bool {
        match self.match_next(0, message) {
            Some(remainders) => {
                remainders.iter().any(|&r| r == "")
            },
            None => false,
        }
    }

    // Returns the remainders after matching one or more rule chains, or `None`.
    fn match_next<'a>(&self, depth: usize, message: &'a str) -> Option<Vec<&'a str>> {
        match &self.rule {
            Rule::None => panic!("no rule found"),
            Rule::Literal(ch) => {
                let m_ch = message.chars().nth(0).unwrap();
                if m_ch == *ch {
                    //eprintln!("depth={} m[{}] Literal({}) *matched* rem[{}]", depth, message, ch, &message[1..]);
                    Some(vec![&message[1..]])
                } else {
                    //eprintln!("depth={} m[{}] Literal({}) not matched", depth, message, ch);
                    None
                }
            },
            Rule::Sequence(_seq) => MatchNode::match_seq(depth, message, &self.left),
            Rule::Branch(_seq1, _seq2) => {
               let mut remainders = vec![];
               if let Some(rems) = MatchNode::match_seq(depth, message, &self.left) {
                   remainders.extend(rems);
               }
               if let Some(rems) = MatchNode::match_seq(depth, message, &self.right) {
                   remainders.extend(rems);
               }
               // FIXME uniqify
                if remainders.is_empty() {
                    return None;
                }
                Some(remainders)
            },
        }
    }

    // Returns the remainders after matching one or more nodes, or `None`.
    fn match_seq<'a>(depth: usize, message: &'a str, seq: &Vec<MatchNode>) -> Option<Vec<&'a str>> {
        let mut remainders = vec![&message[..]];
        for node in seq {
            let mut new_remainders = vec![];
            for rem in remainders {
                if let Some(rems) = node.match_next(depth + 1, rem) {
                    //eprintln!("depth={} rem[{}] Sequence *matched* rems[{:?}]", depth, rem, rems);
                    new_remainders.extend(rems);
                } else {
                    //eprintln!("depth={} rem[{}] Sequence not matched", depth, rem);
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

#[derive(Debug)]
pub struct Ruleset {
    rules: Vec<Rule>,
    n_rules: usize,
    root_node: MatchNode,
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
    /// Construct by reading rules and messages from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<Ruleset> {
        let s: String = fs::read_to_string(path)?;
        let sections: Vec<&str> = s.split("\n\n").collect();
        if sections.len() < 2 {
            let e = format!("expected two sections separated by blank line");
            return Err(RulesetError(e).into());
        }
        let (n_rules, rules) = Rule::from_input(sections[0])?;
        let messages = sections[1].lines().map(|s| s.to_string()).collect();
        let root_node = MatchNode::from_rule(&rules[0], &rules);
        Ok(Self { rules, n_rules, root_node, messages })
    }

    /// How many messages match the rules?
    #[must_use]
    pub fn match_count(&self) -> usize {
        self.messages
            .iter()
            .filter(|m| self.root_node.matches(m))
            .count()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file_1() {
        let ruleset = Ruleset::read_from_file("input/example1.txt").unwrap();
        assert_eq!(4, ruleset.n_rules);
        assert_eq!(4, ruleset.messages.len());
//        eprintln!("example1 = {}", ruleset);
//        eprintln!("example1 match tree = {:#?}", ruleset.root_node);
//        assert_eq!(false, true);
    }

    #[test]
    fn test_read_from_file_2() {
        let ruleset = Ruleset::read_from_file("input/example2.txt").unwrap();
        assert_eq!(6, ruleset.n_rules);
        assert_eq!(5, ruleset.messages.len());
        assert_eq!(Rule::Sequence(vec![4, 1, 5]), ruleset.rules[0]);
        assert_eq!(Rule::Branch(vec![4, 5], vec![5, 4]), ruleset.rules[3]);
        assert_eq!(Rule::Literal('b'), ruleset.rules[5]);
    }

    #[test]
    fn test_read_from_file_no_file() {
        let ruleset = Ruleset::read_from_file("input/example99.txt");
        assert!(ruleset.is_err());
    }

    #[test]
    // see from_input() FIXME above
    #[should_panic]
    fn test_read_from_file_bad_sequence() {
        let _result = Ruleset::read_from_file("input/bad1.txt");
    }

    #[test]
    fn test_read_from_file_no_sections() {
        let result = Ruleset::read_from_file("input/bad2.txt");
        assert!(result.is_err());
    }

    #[test]
    fn test_match_count_1() {
        let ruleset = Ruleset::read_from_file("input/example1.txt").unwrap();
        assert_eq!(2, ruleset.match_count());
    }

    #[test]
    fn test_match_count_2() {
        let ruleset = Ruleset::read_from_file("input/example2.txt").unwrap();
        assert_eq!(2, ruleset.match_count());
    }

    #[test]
    fn test_match_count_3_no_alter() {
        let ruleset = Ruleset::read_from_file("input/example3.txt").unwrap();
        assert_eq!(3, ruleset.match_count());
    }
}
