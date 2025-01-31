T sum<T extends num>(Iterable<T> numbers) =>
    numbers.isEmpty ? 0 as T : numbers.reduce((v, e) => (v + e) as T);
