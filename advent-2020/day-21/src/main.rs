use day_21::FoodList;
use std::time::Instant;

fn main() {
    part1();
    part2();
}

/// Output solution for part 1.
fn part1() {
    let start = Instant::now();
    let food_list = FoodList::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let count = food_list.non_allergen_ingredient_count();
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 1 : {} <=> 2542 expected", count);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

/// Output solution for part 2.
fn part2() {
    let start = Instant::now();
    let food_list = FoodList::read_from_file("input/input.txt").unwrap();
    let gen_time = start.elapsed();
    let dangerous = food_list.dangerous_ingredients();
    let act = dangerous_hash(&dangerous);
    let exp = dangerous_hash("hkflr,ctmcqjf,bfrq,srxphcm,snmxl,zvx,bd,mqvk");
    let run_time = start.elapsed() - gen_time;
    println!("Day 1 - Part 2 : {} <=> {} expected", act, exp);
    println!("    answer: {}", dangerous);
    println!("    generator: {:?}", gen_time);
    println!("    runner: {:?}", run_time);
}

fn dangerous_hash(ingredients: &str) -> String {
    ingredients
        .split(',')
        .map(|ing| format!("{}{}",
                ing.chars().nth(0).unwrap().to_uppercase(),
                ing.chars().nth(1).unwrap())
        )
        .collect::<Vec<String>>()
        .join("")
}
