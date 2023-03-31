use crate::component::Component;
use std::collections::HashMap;

#[derive(Debug, PartialEq)]
pub struct Circuit {
    components: HashMap<String, Component>,
}

impl Circuit {
    pub fn new(input: &str) -> Self {
        let components: HashMap<String, Component> = input
            .lines()
            .map(|line| line.trim().parse::<Component>().unwrap())
            .map(|component| (component.wire_name(), component))
            .collect();
        Self { components }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    pub fn test_circuit_new() {
        let exp1 = "123 -> x";
        let exp2 = "NOT x -> h";
        let c = Circuit::new("123 -> x\nNOT x -> h\n");
        assert_eq!(2, c.components.len(), "new length");
        assert_eq!(exp1, c.components["x"].to_string(), "new exp1");
        assert_eq!(exp2, c.components["h"].to_string(), "new exp2");
    }
}
