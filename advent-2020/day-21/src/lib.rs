use custom_error::custom_error;
use std::fs;
use std::str::FromStr;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

custom_error!{#[derive(PartialEq)]
    pub FoodError
    InvalidLine{line: String} = "invalid food line [{line}]",
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Food {
    ingredients: Vec<String>,
    allergens: Vec<String>,
}

impl FromStr for Food {
    type Err = Box<dyn std::error::Error>;

    fn from_str(line: &str) -> Result<Self> {
        let tokens: Vec<&str> = line.split(" (contains ").collect();
        let ingredients = tokens[0]
            .split(' ')
            .map(|s| String::from(s))
            .collect();
        let allergens = tokens.get(1)
            .ok_or_else(|| FoodError::InvalidLine { line: line.to_string() })?
            .split(", ")
            .map(|s| s.replace(")", ""))
            .collect();
        Ok(Self { ingredients, allergens })
    }
}

#[derive(Debug)]
pub struct FoodList {
    foods: Vec<Food>,
}

impl FoodList {
    /// Returns number of foods.
    #[cfg(test)]
    #[must_use]
    pub fn n_foods(&self) -> usize {
        self.foods.len()
    }

    /// Construct by reading foods from file at `path`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the input file cannot be opened, or if the file
    /// has an invalid format.
    pub fn read_from_file(path: &str) -> Result<FoodList> {
        let s: String = fs::read_to_string(path)?;
        let foods = FoodList::foods_from_input(&s)?;
        Ok(Self { foods })
    }

    // Read foods from `input` (list of lines).
    fn foods_from_input(input: &str) -> Result<Vec<Food>> {
        input.lines().map(str::parse).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_from_file() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(4, food_list.n_foods());
    }
}
