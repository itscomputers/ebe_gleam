import gleam/iterator.{type Iterator, Done, Next}
import gleam/list
import gleeunit
import gleeunit/should

import ebe/primality/eratosthenes.{type Primes}
import ebe/primality/search.{type PrimeSearch}

pub fn main() {
  gleeunit.main()
}

pub fn primes_test() {
  search.new() |> assert_primes(first_primes())
  search.from_sieve([]) |> assert_primes(first_primes())
  search.from_sieve([2]) |> assert_primes(first_primes())
  search.from_sieve([2, 3]) |> assert_primes(first_primes())
  search.from_sieve([2, 3, 5]) |> assert_primes(first_primes())
  search.from_sieve([2, 3, 5, 7]) |> assert_primes(first_primes())
  search.from_sieve([2, 3, 5, 7, 11]) |> assert_primes(first_primes())
}

pub fn advance_test() {
  assert_primes_after(list.range(10, 90))
}

pub fn compatibility_test() {
  compatibility_loop(search.new(), eratosthenes.new(), 100)
}

pub fn take_until_test() {
  search.new()
  |> search.advance(to: 53)
  |> search.take_until(bound: 83)
  |> should.equal([53, 59, 61, 67, 71, 73, 79])
}

fn compatibility_loop(primes: PrimeSearch, eratos: Primes, remaining: Int) {
  primes |> search.next |> should.equal(eratos |> eratosthenes.next)
  case remaining {
    0 -> Nil
    _ ->
      compatibility_loop(
        primes |> search.step,
        eratos |> eratosthenes.step,
        remaining - 1,
      )
  }
}

fn assert_primes_after(lower_values: List(Int)) {
  case lower_values {
    [] -> Nil
    [first, ..rest] -> {
      search.new()
      |> search.advance(first)
      |> assert_primes(
        first_primes() |> iterator.drop_while(fn(n) { n < first }),
      )
      assert_primes_after(rest)
    }
  }
}

fn assert_primes(primes: PrimeSearch, expected: Iterator(Int)) {
  case expected |> iterator.step {
    Next(prime, expected) -> {
      primes |> search.next |> should.equal(prime)
      assert_primes(primes |> search.step, expected)
    }
    Done -> Nil
  }
}

fn first_primes() -> Iterator(Int) {
  [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
    73, 79, 83, 89, 97,
  ]
  |> iterator.from_list
}
