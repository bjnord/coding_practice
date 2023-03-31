use crate::component::Component;

#[derive(Debug, PartialEq)]
pub struct Circuit {
    components: Vec<Component>,
}

impl Circuit {
    pub fn new(input: &str) -> Self {
        let components: Vec<Component> = input
            .lines()
            .map(|line| line.trim().parse::<Component>().unwrap())
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
        assert_eq!(exp1, c.components[0].to_string(), "new exp1");
        assert_eq!(exp2, c.components[1].to_string(), "new exp2");
    }
}
