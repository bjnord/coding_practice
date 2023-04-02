use crate::circuit::CircuitValues;
use lazy_static::lazy_static;
use regex::{Regex, RegexSet};
use std::fmt;
use std::str::FromStr;

#[derive(Debug, PartialEq)]
enum Operand {
    Wire(String),
    Value(u16),
}

impl Operand {
    fn new(o: &str) -> Self {
        let re = Regex::new(r"^\d+$").unwrap();
        if re.is_match(o) {
            // using `unwrap()` here because we know it's purely digits
            Self::Value(o.parse::<u16>().unwrap())
        } else {
            Self::Wire(o.to_string())
        }
    }
}

impl fmt::Display for Operand {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::Wire(w) => write!(f, "{}", w),
            Self::Value(v) => write!(f, "{}", v),
        }
    }
}

#[derive(Debug, PartialEq)]
enum ComponentSource {
    Input(Operand),
    ANDGate(Operand, Operand),
    ORGate(Operand, Operand),
    NOTGate(Operand),
    LSHIFTGate(Operand, u16),
    RSHIFTGate(Operand, u16),
}

pub type ComponentValue = Option<u16>;

#[derive(Debug, PartialEq)]
pub struct Component {
    source: ComponentSource,
    sink_wire: String,
    value: ComponentValue,
}

impl FromStr for Component {
    type Err = std::string::ParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let tokens: Vec<&str> = s.split_whitespace().collect();
        lazy_static! {
            static ref RE_SET: RegexSet = RegexSet::new([
                r"^\w+\s+->\s+\w+$",
                r"^\w+\s+(?:AND|OR)\s+\w+\s+->\s+\w+$",
                r"^NOT\s+\w+\s+->\s+\w+$",
                r"^\w+\s+(?:LSHIFT|RSHIFT)\s+\d+\s+->\s+\w+$",
            ])
            .unwrap();
        }
        let matches: Vec<_> = RE_SET.matches(s).into_iter().collect();
        match (matches[0], tokens[1]) {
            (0, _) => Ok(Self {
                source: ComponentSource::Input(Operand::new(tokens[0])),
                sink_wire: tokens[2].to_string(),
                value: None,
            }),
            (1, "AND") => Ok(Self {
                source: ComponentSource::ANDGate(Operand::new(tokens[0]), Operand::new(tokens[2])),
                sink_wire: tokens[4].to_string(),
                value: None,
            }),
            (1, "OR") => Ok(Self {
                source: ComponentSource::ORGate(Operand::new(tokens[0]), Operand::new(tokens[2])),
                sink_wire: tokens[4].to_string(),
                value: None,
            }),
            (2, _) => Ok(Self {
                source: ComponentSource::NOTGate(Operand::new(tokens[1])),
                sink_wire: tokens[3].to_string(),
                value: None,
            }),
            (3, "LSHIFT") => Ok(Self {
                // using `unwrap()` here because we know it's purely digits
                source: ComponentSource::LSHIFTGate(
                    Operand::new(tokens[0]),
                    tokens[2].parse::<u16>().unwrap(),
                ),
                sink_wire: tokens[4].to_string(),
                value: None,
            }),
            (3, "RSHIFT") => Ok(Self {
                // using `unwrap()` here because we know it's purely digits
                source: ComponentSource::RSHIFTGate(
                    Operand::new(tokens[0]),
                    tokens[2].parse::<u16>().unwrap(),
                ),
                sink_wire: tokens[4].to_string(),
                value: None,
            }),
            (_, _) => {
                panic!("unknown component {}", s);
            }
        }
    }
}

impl fmt::Display for Component {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match &self.source {
            ComponentSource::Input(o) => write!(f, "{} -> {}", o, self.sink_wire),
            ComponentSource::ANDGate(o1, o2) => {
                write!(f, "{} AND {} -> {}", o1, o2, self.sink_wire)
            }
            ComponentSource::ORGate(o1, o2) => write!(f, "{} OR {} -> {}", o1, o2, self.sink_wire),
            ComponentSource::NOTGate(o) => write!(f, "NOT {} -> {}", o, self.sink_wire),
            ComponentSource::LSHIFTGate(o, n) => {
                write!(f, "{} LSHIFT {} -> {}", o, n, self.sink_wire)
            }
            ComponentSource::RSHIFTGate(o, n) => {
                write!(f, "{} RSHIFT {} -> {}", o, n, self.sink_wire)
            }
        }
        // TODO then write `self.value`
    }
}

impl Component {
    #[must_use]
    pub fn wire_name(&self) -> String {
        self.sink_wire.to_string()
    }

    #[must_use]
    pub fn wire_value(&self) -> ComponentValue {
        self.value
    }

    pub fn solve(&mut self, circuit_values: &CircuitValues) {
        match &self.source {
            ComponentSource::Input(o) => {
                self.value = match o {
                    Operand::Value(v) => Some(*v),
                    Operand::Wire(w) => circuit_values[w],
                }
            }
            ComponentSource::ANDGate(o1, o2) => {
                let o1_value = match o1 {
                    Operand::Value(v1) => Some(*v1),
                    Operand::Wire(w1) => circuit_values[w1],
                };
                let o2_value = match o2 {
                    Operand::Value(v2) => Some(*v2),
                    Operand::Wire(w2) => circuit_values[w2],
                };
                self.value = match (o1_value, o2_value) {
                    (Some(v1), Some(v2)) => Some(v1 & v2),
                    (_, _) => None,
                }
            }
            ComponentSource::ORGate(o1, o2) => {
                let o1_value = match o1 {
                    Operand::Value(v1) => Some(*v1),
                    Operand::Wire(w1) => circuit_values[w1],
                };
                let o2_value = match o2 {
                    Operand::Value(v2) => Some(*v2),
                    Operand::Wire(w2) => circuit_values[w2],
                };
                self.value = match (o1_value, o2_value) {
                    (Some(v1), Some(v2)) => Some(v1 | v2),
                    (_, _) => None,
                }
            }
            ComponentSource::NOTGate(o) => {
                self.value = match o {
                    Operand::Value(v) => Some(!(*v)),
                    Operand::Wire(w) => circuit_values[w].map(|v| !v),
                }
            }
            ComponentSource::LSHIFTGate(o, n) => {
                let o_value = match o {
                    Operand::Value(v) => Some(*v),
                    Operand::Wire(w) => circuit_values[w],
                };
                self.value = o_value.map(|v| v << n);
            }
            ComponentSource::RSHIFTGate(o, n) => {
                let o_value = match o {
                    Operand::Value(v) => Some(*v),
                    Operand::Wire(w) => circuit_values[w],
                };
                self.value = o_value.map(|v| v >> n);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    // "123 -> x means that the signal 123 is provided to wire x."
    #[test]
    fn test_component_parse_ex1() {
        let exp_cs = ComponentSource::Input(Operand::Value(123));
        let exp = Component {
            source: exp_cs,
            sink_wire: "x".to_string(),
            value: None,
        };
        let c: Component = "123 -> x".parse().unwrap();
        assert_eq!(exp, c, "ex1");
        assert_eq!("123 -> x", c.to_string(), "ex1 to_string");
        assert_eq!("x", c.wire_name(), "ex1 wire_name");
    }

    // "x AND y -> z means that the bitwise AND of wire x and wire y is provided to wire z."
    #[test]
    fn test_component_parse_ex2a() {
        let exp_cs = ComponentSource::ANDGate(
            Operand::Wire("x".to_string()),
            Operand::Wire("y".to_string()),
        );
        let exp = Component {
            source: exp_cs,
            sink_wire: "z".to_string(),
            value: None,
        };
        let c: Component = "x AND y -> z".parse().unwrap();
        assert_eq!(exp, c, "ex2a");
        assert_eq!("x AND y -> z", c.to_string(), "ex2a to_string");
        assert_eq!("z", c.wire_name(), "ex2a wire_name");
    }
    #[test]
    fn test_component_parse_ex2b() {
        let exp_cs = ComponentSource::ORGate(Operand::Wire("b".to_string()), Operand::Value(6));
        let exp = Component {
            source: exp_cs,
            sink_wire: "jn".to_string(),
            value: None,
        };
        let c: Component = "b OR 6 -> jn".parse().unwrap();
        assert_eq!(exp, c, "ex2b");
        assert_eq!("b OR 6 -> jn", c.to_string(), "ex2b to_string");
        assert_eq!("jn", c.wire_name(), "ex2b wire_name");
    }
    #[test]
    fn test_component_parse_ex2c() {
        let exp_cs = ComponentSource::ANDGate(Operand::Value(3), Operand::Wire("a".to_string()));
        let exp = Component {
            source: exp_cs,
            sink_wire: "my".to_string(),
            value: None,
        };
        let c: Component = "3 AND a -> my".parse().unwrap();
        assert_eq!(exp, c, "ex2c");
        assert_eq!("3 AND a -> my", c.to_string(), "ex2c to_string");
        assert_eq!("my", c.wire_name(), "ex2c wire_name");
    }

    // "p LSHIFT 2 -> q means that the value from wire p is left-shifted by 2 and then provided to
    // wire q."
    #[test]
    fn test_component_parse_ex3a() {
        let exp_cs = ComponentSource::LSHIFTGate(Operand::Wire("p".to_string()), 2);
        let exp = Component {
            source: exp_cs,
            sink_wire: "q".to_string(),
            value: None,
        };
        let c: Component = "p LSHIFT 2 -> q".parse().unwrap();
        assert_eq!(exp, c, "ex3a");
        assert_eq!("p LSHIFT 2 -> q", c.to_string(), "ex3a to_string");
        assert_eq!("q", c.wire_name(), "ex3a wire_name");
    }
    #[test]
    fn test_component_parse_ex3b() {
        let exp_cs = ComponentSource::RSHIFTGate(Operand::Wire("q".to_string()), 2);
        let exp = Component {
            source: exp_cs,
            sink_wire: "p".to_string(),
            value: None,
        };
        let c: Component = "q RSHIFT 2 -> p".parse().unwrap();
        assert_eq!(exp, c, "ex3b");
        assert_eq!("q RSHIFT 2 -> p", c.to_string(), "ex3b to_string");
        assert_eq!("p", c.wire_name(), "ex3b wire_name");
    }

    // "NOT e -> f means that the bitwise complement of the value from wire e is provided to wire
    // f."
    #[test]
    fn test_component_parse_ex4() {
        let exp_cs = ComponentSource::NOTGate(Operand::Wire("e".to_string()));
        let exp = Component {
            source: exp_cs,
            sink_wire: "f".to_string(),
            value: None,
        };
        let c: Component = "NOT e -> f".parse().unwrap();
        assert_eq!(exp, c, "ex4");
        assert_eq!("NOT e -> f", c.to_string(), "ex4 to_string");
        assert_eq!("f", c.wire_name(), "ex4 wire_name");
    }

    // TODO test_component_parse_invalid

    // "123 -> x means that the signal 123 is provided to wire x."
    #[test]
    fn test_component_solve_ex1() {
        let mut comp: Component = "123 -> x".parse().unwrap();
        let cv = CircuitValues::new();
        comp.solve(&cv);
        assert_eq!(123, comp.wire_value().unwrap(), "solve_ex1 value");
    }
    #[test]
    fn test_component_solve_ex1_w() {
        let mut comp: Component = "y -> x".parse().unwrap();
        let cv = HashMap::from([("y".to_string(), Some(123_u16))]);
        comp.solve(&cv);
        assert_eq!(123, comp.wire_value().unwrap(), "solve_ex1_w value");
    }

    // "x AND y -> z means that the bitwise AND of wire x and wire y is provided to wire z."
    #[test]
    fn test_component_solve_ex2a() {
        let mut comp: Component = "x AND y -> z".parse().unwrap();
        let cv = HashMap::from([
            ("x".to_string(), Some(65_u16)),
            ("y".to_string(), Some(192_u16)),
        ]);
        comp.solve(&cv);
        assert_eq!(64, comp.wire_value().unwrap(), "solve_ex2a value");
    }
    #[test]
    fn test_component_solve_ex2a_v() {
        let mut comp: Component = "65 AND 192 -> z".parse().unwrap();
        let cv = CircuitValues::new();
        comp.solve(&cv);
        assert_eq!(64, comp.wire_value().unwrap(), "solve_ex2a_v value");
    }
    #[test]
    fn test_component_solve_ex2b() {
        let mut comp: Component = "x OR y -> z".parse().unwrap();
        let cv = HashMap::from([
            ("x".to_string(), Some(65_u16)),
            ("y".to_string(), Some(192_u16)),
        ]);
        comp.solve(&cv);
        assert_eq!(193, comp.wire_value().unwrap(), "solve_ex2b value");
    }
    #[test]
    fn test_component_solve_ex2b_v() {
        let mut comp: Component = "65 OR 192 -> z".parse().unwrap();
        let cv = CircuitValues::new();
        comp.solve(&cv);
        assert_eq!(193, comp.wire_value().unwrap(), "solve_ex2b_v value");
    }

    // "p LSHIFT 2 -> q means that the value from wire p is left-shifted by 2 and then provided to
    // wire q."
    #[test]
    fn test_component_solve_ex3a() {
        let mut comp: Component = "p LSHIFT 2 -> q".parse().unwrap();
        let cv = HashMap::from([("p".to_string(), Some(65_u16))]);
        comp.solve(&cv);
        assert_eq!(260, comp.wire_value().unwrap(), "solve_ex3a value");
    }
    #[test]
    fn test_component_solve_ex3a_v() {
        let mut comp: Component = "65 LSHIFT 2 -> q".parse().unwrap();
        let cv = CircuitValues::new();
        comp.solve(&cv);
        assert_eq!(260, comp.wire_value().unwrap(), "solve_ex3a_v value");
    }
    #[test]
    fn test_component_solve_ex3b() {
        let mut comp: Component = "p RSHIFT 2 -> p".parse().unwrap();
        let cv = HashMap::from([("p".to_string(), Some(193_u16))]);
        comp.solve(&cv);
        assert_eq!(48, comp.wire_value().unwrap(), "solve_ex3b value");
    }
    #[test]
    fn test_component_solve_ex3b_v() {
        let mut comp: Component = "193 RSHIFT 2 -> p".parse().unwrap();
        let cv = CircuitValues::new();
        comp.solve(&cv);
        assert_eq!(48, comp.wire_value().unwrap(), "solve_ex3b_v value");
    }

    // "NOT e -> f means that the bitwise complement of the value from wire e is provided to wire
    // f."
    #[test]
    fn test_component_solve_ex4() {
        let mut comp: Component = "NOT e -> f".parse().unwrap();
        let cv = HashMap::from([("e".to_string(), Some(123_u16))]);
        comp.solve(&cv);
        assert_eq!(65412, comp.wire_value().unwrap(), "solve_ex4 value");
    }
    #[test]
    fn test_component_solve_ex4_v() {
        let mut comp: Component = "NOT 123 -> f".parse().unwrap();
        let cv = CircuitValues::new();
        comp.solve(&cv);
        assert_eq!(65412, comp.wire_value().unwrap(), "solve_ex4_v value");
    }
}
