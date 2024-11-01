//// Primality module

import ebe/primality/algorithm
import ebe/primality/iterator.{type Primes} as iter
import ebe/primality/observation.{Prime}

import gleam/list

/// List of primes less than a number
pub fn primes_before(number: Int) -> List(Int) {
  primes_before_loop(number, iter.new(), [])
}

/// Prime list - recursive function
fn primes_before_loop(
  number: Int,
  primes: Primes,
  curr_list: List(Int),
) -> List(Int) {
  case primes |> iter.next {
    prime if prime < number ->
      primes_before_loop(number, primes |> iter.advance, [prime, ..curr_list])
    _ -> curr_list |> list.reverse
  }
}

/// Primality
///   - deterministic result if number < 341_550_071_728_321 
///   - probabilistic result otherwise
///       - probability of incorrect classification < 4^(-10) for Miller-Rabin test
pub fn is_prime(number: Int) -> Bool {
  case number |> algorithm.primality_observation |> observation.concretize {
    Prime -> True
    _ -> False
  }
}

/// Naive primality
pub fn is_prime_naive(number: Int) -> Bool {
  case number < 2 {
    True -> False
    _ -> is_prime_naive_loop(number, iter.new())
  }
}

/// Naive primality - recursive function
fn is_prime_naive_loop(number, primes: Primes) -> Bool {
  case primes |> iter.next {
    prime if prime * prime <= number ->
      case number % prime == 0 {
        True -> False
        False -> is_prime_naive_loop(number, primes |> iter.advance)
      }
    _ -> True
  }
}
