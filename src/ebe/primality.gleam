//// Primality module

import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/order.{Lt}

/// Primes iterator
pub opaque type Primes {
  Primes(next: Int, iter: Iterator(Int))
}

/// Construct primes iterator
pub fn primes() -> Primes {
  Primes(2, iterator.iterate(3, fn(n) { n + 2 }))
}

/// Next prime in iterator
pub fn next(primes: Primes) -> Int {
  primes.next
}

/// Advance the primes iterator
pub fn advance(primes: Primes) -> Primes {
  case primes.iter |> iterator.first {
    Ok(prime) ->
      Primes(prime, primes.iter |> iterator.filter(fn(n) { n % prime != 0 }))
    Error(Nil) -> panic
  }
}

/// List of primes less than a number
pub fn primes_before(number: Int) -> List(Int) {
  primes_before_loop(number, primes(), [])
}

/// Prime list - recursive function
fn primes_before_loop(
  number: Int,
  primes: Primes,
  curr_list: List(Int),
) -> List(Int) {
  case primes.next {
    prime if prime < number ->
      primes_before_loop(number, primes |> advance, [prime, ..curr_list])
    _ -> curr_list |> list.reverse
  }
}

/// Naive primality
pub fn is_prime_naive(number: Int) -> Bool {
  case number |> int.compare(2) {
    Lt -> False
    _ -> is_prime_naive_loop(number, primes())
  }
}

/// Naive primality - recursive function
fn is_prime_naive_loop(number, primes: Primes) -> Bool {
  case primes.next {
    prime if prime * prime <= number ->
      case number % prime == 0 {
        True -> False
        False -> is_prime_naive_loop(number, primes |> advance)
      }
    _ -> True
  }
}
