use crate::component::{Component, ComponentValue};
use std::collections::HashMap;

pub type CircuitValues = HashMap<String, ComponentValue>;

#[derive(Debug, PartialEq)]
pub struct Circuit {
    components: HashMap<String, Component>,
}

impl Circuit {
    /// # Panics
    ///
    /// Panics if an invalid component is found.
    #[must_use]
    pub fn new(input: &str) -> Self {
        let components: HashMap<String, Component> = input
            .lines()
            .map(|line| line.trim().parse::<Component>().unwrap())
            .map(|component| (component.wire_name(), component))
            .collect();
        Self { components }
    }

    #[must_use]
    pub fn values(&self) -> CircuitValues {
        self.components
            .values()
            .map(|c| (c.wire_name(), c.wire_value()))
            .collect()
    }

    #[must_use]
    pub fn value_of(&self, wire_name: &str) -> ComponentValue {
        self.components[wire_name].wire_value()
    }

    #[must_use]
    pub fn is_solved(&self) -> bool {
        self.components.values().all(|c| c.wire_value().is_some())
    }

    pub fn solve(&mut self) {
        while !self.is_solved() {
            let cur_values = self.values();
            for component in self.components.values_mut() {
                component.solve(&cur_values);
            }
        }
    }

    pub fn override_wire(&mut self, wire_name: &str, wire_value: ComponentValue) {
        let input = format!("{} -> {}", wire_value.unwrap(), wire_name);
        let input_component = input.parse::<Component>().unwrap();
        self.components
            .entry(wire_name.to_string())
            .and_modify(|c| *c = input_component);
    }

    pub fn reset(&mut self) {
        for component in self.components.values_mut() {
            component.reset_wire_value();
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    #[test]
    pub fn test_circuit_new() {
        let exp1 = "123 -> x";
        let exp2 = "NOT x -> h";
        let c = Circuit::new("123 -> x\nNOT x -> h\n");
        assert_eq!(2, c.components.len(), "new length");
        assert_eq!(exp1, c.components["x"].to_string(), "new exp1");
        assert_eq!(exp2, c.components["h"].to_string(), "new exp2");
    }

    #[test]
    pub fn test_circuit_solve() {
        let mut c = Circuit::new(
            "123 -> x
            456 -> y
            x AND y -> d
            x OR y -> e
            x LSHIFT 2 -> f
            y RSHIFT 2 -> g
            NOT x -> h
            NOT y -> i",
        );
        assert_eq!(None, c.value_of("d"), "circuit value_of d before");
        c.solve();
        let exp = HashMap::from([
            ("d".to_string(), Some(72_u16)),
            ("e".to_string(), Some(507_u16)),
            ("f".to_string(), Some(492_u16)),
            ("g".to_string(), Some(114_u16)),
            ("h".to_string(), Some(65412_u16)),
            ("i".to_string(), Some(65079_u16)),
            ("x".to_string(), Some(123_u16)),
            ("y".to_string(), Some(456_u16)),
        ]);
        assert_eq!(exp, c.values(), "circuit solve");
        assert_eq!(Some(72_u16), c.value_of("d"), "circuit value_of d after");
    }

    #[test]
    pub fn test_circuit_override_wire_and_reset() {
        let mut c = Circuit::new("123 -> x\nNOT x -> h\n");
        c.solve();
        assert_eq!(Some(123_u16), c.value_of("x"), "circuit value_of x before");
        assert_eq!(Some(65412_u16), c.value_of("h"), "circuit value_of h before");
        c.override_wire("x", Some(12300));
        c.reset();
        c.solve();
        assert_eq!(Some(12300_u16), c.value_of("x"), "circuit value_of x after");
        assert_eq!(Some(53235_u16), c.value_of("h"), "circuit value_of h after");
    }

    #[test]
    #[should_panic]
    pub fn test_circuit_override_wire_not_found() {
        let mut c = Circuit::new("123 -> x\n");
        c.override_wire("y", Some(45600));
        let _v = c.value_of("y");
    }
}
