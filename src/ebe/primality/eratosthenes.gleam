//// Primes iterator module

import gleam/iterator.{type Iterator}

/// Primes iterator
pub opaque type Primes {
  Primes(next: Int, iter: Iterator(Int))
}

/// Construct primes iterator
pub fn new() -> Primes {
  Primes(2, iterator.iterate(3, fn(n) { n + 2 }))
}

/// Next prime in iterator
pub fn next(primes: Primes) -> Int {
  primes.next
}

/// Advance the primes iterator
pub fn step(primes: Primes) -> Primes {
  case primes.iter |> iterator.first {
    Ok(prime) ->
      Primes(prime, primes.iter |> iterator.filter(fn(n) { n % prime != 0 }))
    Error(Nil) -> panic
  }
}
