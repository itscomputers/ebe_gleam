//// Primality module

import ebe/primality/algorithm
import ebe/primality/eratosthenes.{type Primes}
import ebe/primality/search

/// Primality determination
pub fn is_prime(number: Int) -> Bool {
  number |> algorithm.is_prime
}

/// List of primes less than a number
pub fn primes_before(number: Int) -> List(Int) {
  search.new() |> search.take_until(bound: number)
}

/// List of primes bewteen lower bound (inclusive) and upper bound (exclusive)
pub fn primes_in_range(from lower: Int, to upper: Int) {
  search.new() |> search.advance(to: lower) |> search.take_until(bound: upper)
}

/// Naive primality
pub fn is_prime_naive(number: Int) -> Bool {
  case number < 2 {
    True -> False
    _ -> is_prime_naive_loop(number, eratosthenes.new())
  }
}

/// Naive primality - recursive function
fn is_prime_naive_loop(number, primes: Primes) -> Bool {
  case primes |> eratosthenes.next {
    prime if prime * prime <= number ->
      case number % prime == 0 {
        True -> False
        False -> is_prime_naive_loop(number, primes |> eratosthenes.step)
      }
    _ -> True
  }
}
