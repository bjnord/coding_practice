use custom_error::custom_error;
use std::collections::HashSet;
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

impl Food {
    /// Return list of all ingredients in the food.
    #[must_use]
    pub fn ingredients(&self) -> Vec<String> {
        self.ingredients.iter().cloned().collect()
    }

    /// Return list of all declared allergens in the food.
    #[must_use]
    pub fn allergens(&self) -> Vec<String> {
        self.allergens.iter().cloned().collect()
    }

    /// Does this food contain `ingredient`?
    #[must_use]
    pub fn contains_ingredient(&self, ingredient: &str) -> bool {
        self.ingredients
            .iter()
            .find(|ing| &ing[..] == ingredient)
            .is_some()
    }

    /// Is this food known to contain `allergen`?
    #[must_use]
    pub fn contains_allergen(&self, allergen: &str) -> bool {
        self.allergens
            .iter()
            .find(|all| &all[..] == allergen)
            .is_some()
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

    /// Return list of all declared allergens in the food list.
    #[must_use]
    pub fn all_allergens(&self) -> Vec<String> {
        let mut allergens: Vec<String> = self.foods
            .iter()
            .map(|food| food.allergens())
            .flatten()
            .collect();
        allergens.sort();
        allergens.dedup();
        allergens
    }

    /// Return list of all ingredients in the food list.
    #[must_use]
    pub fn all_ingredients(&self) -> Vec<String> {
        let mut ingredients: Vec<String> = self.foods
            .iter()
            .map(|food| food.ingredients())
            .flatten()
            .collect();
        ingredients.sort();
        ingredients.dedup();
        ingredients
    }

    /// Return list of all non-allergen ingredients in the food list.
    #[must_use]
    pub fn non_allergen_ingredients(&self) -> Vec<String> {
        let known: Vec<String> = self.known_allergen_ingredients()
            .iter()
            .map(|pair| pair.0.to_string())
            .collect();
        self.all_ingredients()
            .iter()
            .filter(|ing| !known.contains(ing))
            .map(|ing| ing.to_string())
            .collect()
    }

    /// Return count of non-allergen ingredient appearances in the food
    /// list.
    #[must_use]
    pub fn non_allergen_ingredient_count(&self) -> usize {
        self.non_allergen_ingredients()
            .iter()
            .map(|ing| self.ingredient_count(&ing[..]))
            .sum()
    }

    /// Return count of ingredient appearances in the food list.
    #[must_use]
    pub fn ingredient_count(&self, ingredient: &str) -> usize {
        self.foods
            .iter()
            .filter(|&food| food.contains_ingredient(ingredient))
            .count()
    }

    /// Return the "canonical dangerous ingredient list" string.
    pub fn dangerous_ingredients(&self) -> String {
        let mut ka_ingredients: Vec<(String, String)> = self.known_allergen_ingredients();
        ka_ingredients.sort_by(|a, b| a.1.cmp(&b.1));
        ka_ingredients
            .iter()
            .map(|pair| pair.0.to_string())
            .collect::<Vec<String>>()
            .join(",")
    }

    /// Return list of ingredients with known allergens. Each item in the
    /// list is an (ingredient, allergen) tuple.
    #[must_use]
    pub fn known_allergen_ingredients(&self) -> Vec<(String, String)> {
        let mut allergens: HashSet<String> =
            self.all_allergens().iter().cloned().collect();
        let mut a_ingredients: Vec<(String, String)> = vec![];
        while !allergens.is_empty() {
            let mut discovery = false;
            // 1. "When you come to a fork in the road, take it."
            let loners: Vec<(&String, &String)> = self.foods
                .iter()
                .filter_map(|food| FoodList::lone_allergen_ingredient(food, &a_ingredients))
                .collect();
            if loners.len() > 0 {
                for loner in loners {
                    allergens.remove(loner.1);
                    a_ingredients.push((loner.0.to_string(), loner.1.to_string()));
                }
                discovery = true;
            }
            // 2. "A: One of its legs are both the same."
            let mut commons: Vec<(String, String)> = vec![];
            for allergen in allergens.iter() {
                let a_commons: Vec<(String, String)> = self.common_ingredients(&allergen)
                    .iter()
                    .filter(|c_pair|
                        !a_ingredients
                            .iter()
                            .map(|i_pair| i_pair.0.to_string())
                            .collect::<Vec<String>>()
                            .contains(&c_pair.0)
                    )
                    .cloned()
                    .collect();
                if a_commons.len() == 1 {
                    commons.push((a_commons[0].0.to_string(), a_commons[0].1.to_string()));
                    break;
                }
            }
            for common in &commons {
                allergens.remove(&common.1);
                a_ingredients.push((common.0.to_string(), common.1.to_string()));
                discovery = true;
            }
            if !discovery {
                eprintln!("! allergens = {:?}", allergens);
                eprintln!("! a_ingredients = {:?}", a_ingredients);
                panic!("stuck");
            }
        }
        a_ingredients
    }

    fn lone_allergen_ingredient<'a>(food: &'a Food, a_ingredients: &Vec<(String, String)>) -> Option<(&'a String, &'a String)> {
        let unknown_a = FoodList::unknown_allergens(food, a_ingredients);
        if unknown_a.len() != 1 {
            return None;
        }
        let unknown_i = FoodList::unknown_ingredients(food, a_ingredients);
        if unknown_i.len() != 1 {
            return None;
        }
        Some((unknown_i[0], unknown_a[0]))
    }

    fn unknown_allergens<'a>(food: &'a Food, a_ingredients: &Vec<(String, String)>) -> Vec<&'a String> {
        food.allergens
            .iter()
            .filter(|&all|
                !a_ingredients
                    .iter()
                    .any(|pair| pair.1 == *all)
            )
            .collect()
    }

    fn unknown_ingredients<'a>(food: &'a Food, a_ingredients: &Vec<(String, String)>) -> Vec<&'a String> {
        food.ingredients
            .iter()
            .filter(|&ing|
                !a_ingredients
                    .iter()
                    .any(|pair| pair.0 == *ing)
            )
            .collect()
    }

    /// Return list of ingredients common to all foods containing `allergen`.
    /// Each item in the list is an (ingredient, allergen) tuple.
    #[must_use]
    pub fn common_ingredients(&self, allergen: &str) -> Vec<(String, String)> {
        let a_foods: Vec<&Food> = self.foods
            .iter()
            .filter(|food| food.contains_allergen(allergen))
            .collect();
        if a_foods.is_empty() {
            return vec![];
        }
        a_foods[0].ingredients
            .iter()
            .filter(|ing| a_foods.iter().all(|food| food.contains_ingredient(ing)))
            .map(|ing| (ing.to_string(), allergen.to_string()))
            .collect()
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

    #[test]
    fn test_all_allergens() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(vec!["dairy", "fish"], food_list.foods[0].allergens());
        let mut actual = food_list.all_allergens();
        actual.sort();
        assert_eq!(vec!["dairy", "fish", "soy"], actual);
    }

    #[test]
    fn test_all_ingredients() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(vec!["sqjhc", "fvjkl"], food_list.foods[2].ingredients());
        let mut actual = food_list.all_ingredients();
        actual.sort();
        assert_eq!(vec!["fvjkl", "kfcds", "mxmxvkd", "nhms", "sbzzf", "sqjhc", "trh"], actual);
    }

    #[test]
    fn test_contains_ingredient() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(true, food_list.foods[0].contains_ingredient("mxmxvkd"));
        assert_eq!(false, food_list.foods[0].contains_ingredient("kltpzyxm"));
        assert_eq!(true, food_list.foods[1].contains_ingredient("mxmxvkd"));
        assert_eq!(false, food_list.foods[2].contains_ingredient("mxmxvkd"));
        assert_eq!(true, food_list.foods[1].contains_ingredient("fvjkl"));
        assert_eq!(false, food_list.foods[1].contains_ingredient("mayonnaise"));
        assert_eq!(true, food_list.foods[2].contains_ingredient("fvjkl"));
        assert_eq!(false, food_list.foods[3].contains_ingredient("fvjkl"));
    }

    #[test]
    fn test_contains_allergen() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(false, food_list.foods[0].contains_allergen("gluten"));
        assert_eq!(true, food_list.foods[0].contains_allergen("dairy"));
        assert_eq!(true, food_list.foods[0].contains_allergen("fish"));
        assert_eq!(false, food_list.foods[2].contains_allergen("dairy"));
        assert_eq!(true, food_list.foods[2].contains_allergen("soy"));
    }

    #[test]
    fn test_known_allergen_ingredients() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        let expected: Vec<(String, String)> = vec![
            ("mxmxvkd".to_string(), "dairy".to_string()),
            ("sqjhc".to_string(), "fish".to_string()),
            ("fvjkl".to_string(), "soy".to_string()),
        ];
        let mut actual = food_list.known_allergen_ingredients();
        actual.sort_by(|a, b| a.1.cmp(&b.1));
        assert_eq!(expected, actual);
    }

    #[test]
    fn test_dangerous_ingredients() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!("mxmxvkd,sqjhc,fvjkl", food_list.dangerous_ingredients());
    }

    #[test]
    fn test_non_allergen_ingredients() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        let mut actual = food_list.non_allergen_ingredients();
        actual.sort();
        assert_eq!(vec!["kfcds", "nhms", "sbzzf", "trh"], actual);
    }

    #[test]
    fn test_ingredient_count() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(1, food_list.ingredient_count("trh"));
        assert_eq!(2, food_list.ingredient_count("sbzzf"));
        assert_eq!(3, food_list.ingredient_count("sqjhc"));
    }

    #[test]
    fn test_non_allergen_ingredient_count() {
        let food_list = FoodList::read_from_file("input/example1.txt").unwrap();
        assert_eq!(5, food_list.non_allergen_ingredient_count());
    }
}
