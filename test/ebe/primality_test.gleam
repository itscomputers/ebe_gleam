import ebe/primality.{type Primes}
import gleam/bool
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn next_prime_test() {
  let assert_next_prime = fn(primes: Primes, expected: Int) -> Primes {
    primes.next |> should.equal(expected)
    primes |> primality.advance
  }

  primality.primes()
  |> assert_next_prime(2)
  |> assert_next_prime(3)
  |> assert_next_prime(5)
  |> assert_next_prime(7)
  |> assert_next_prime(11)
  |> assert_next_prime(13)
  |> assert_next_prime(17)
  |> assert_next_prime(19)
  |> assert_next_prime(23)
}

pub fn primes_before_test() {
  primality.primes_before(29)
  |> should.equal(
    primes_up_to_100()
    |> list.take_while(fn(p) { p < 29 }),
  )
  primality.primes_before(101)
  |> should.equal(primes_up_to_100())
}

pub fn is_prime_naive_test() {
  primes_up_to_100()
  |> list.map(primality.is_prime_naive)
  |> list.all(fn(b) { b })
  |> should.be_true

  non_primes_up_to_100()
  |> list.map(primality.is_prime_naive)
  |> list.any(fn(b) { b })
  |> should.be_false
}

fn primes_up_to_100() {
  [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
    73, 79, 83, 89, 97,
  ]
}

fn non_primes_up_to_100() {
  list.range(-5, 100)
  |> list.filter(fn(a) { primes_up_to_100() |> list.contains(a) |> bool.negate })
}
