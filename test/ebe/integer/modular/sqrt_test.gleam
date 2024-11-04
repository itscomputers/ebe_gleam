import ebe/integer
import ebe/integer/modular
import ebe/integer/modular/sqrt.{type SquareRoot, SquareRoot}
import ebe/primality

import gleam/list

import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn sqrt_test() {
  primality.primes_before(40)
  |> list.each(fn(prime) {
    squares(prime)
    |> list.each(fn(number) {
      prime |> sqrt.sqrt(number) |> check_sqrt_ok(number)
    })

    non_squares(prime)
    |> list.each(fn(number) { prime |> sqrt.sqrt(number) |> check_sqrt_error })
  })

  [1, 4, 6, 8, 9, 12, 14, 15, 16, 18, 20]
  |> list.each(fn(non_prime) {
    list.range(1, non_prime - 1)
    |> list.each(fn(number) {
      non_prime |> sqrt.sqrt(number) |> check_sqrt_error
    })
  })
}

pub fn sqrt_negative_one_test() {
  primality.primes_before(40)
  |> list.filter(fn(prime) { prime |> integer.mod(4) == 1 })
  |> list.each(fn(prime) {
    let root = prime |> sqrt.sqrt(-1)
    root |> should.equal(prime |> sqrt.wilson)
    root |> should.equal(prime |> sqrt.legendre)
  })

  primality.primes_before(40)
  |> list.filter(fn(prime) { prime |> integer.mod(4) == 3 })
  |> list.each(fn(prime) {
    prime |> sqrt.sqrt(-1) |> should.be_error
    prime |> sqrt.wilson |> should.be_error
    prime |> sqrt.legendre |> should.be_error
  })
}

fn check_sqrt_ok(root: Result(SquareRoot, Nil), number: Int) {
  let assert Ok(SquareRoot(root, other_root, prime)) = root
  [root, other_root]
  |> list.each(fn(root) {
    root
    |> modular.exp_unsafe(2, prime)
    |> should.equal(number |> integer.mod(prime))
  })
}

fn check_sqrt_error(root: Result(SquareRoot, Nil)) {
  root |> should.be_error
}

fn squares(prime: Int) -> List(Int) {
  list.range(1, prime - 1)
  |> list.map(fn(number) { number |> modular.exp_unsafe(2, prime) })
  |> list.unique
}

fn non_squares(prime: Int) -> List(Int) {
  let sqs = squares(prime)
  list.range(1, prime - 1)
  |> list.filter(fn(number) { !list.contains(sqs, number) })
}
