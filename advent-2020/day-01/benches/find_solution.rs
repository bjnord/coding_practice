use criterion::{criterion_group, criterion_main, Criterion};
use day_01::{Entry, ENTRY_SUM};

pub fn bench_find_solution_for_2(c: &mut Criterion) {
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    c.bench_function("solve 2", |b| b.iter(|| Entry::find_solution(&entries, 2, ENTRY_SUM)));
}

pub fn bench_find_solution_for_3(c: &mut Criterion) {
    let entries = Entry::read_from_file("input/input.txt").unwrap();
    c.bench_function("solve 3", |b| b.iter(|| Entry::find_solution(&entries, 3, ENTRY_SUM)));
}

criterion_group!(benches, bench_find_solution_for_2, bench_find_solution_for_3);
criterion_main!(benches);
