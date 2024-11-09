import gleam/list
import gleeunit
import gleeunit/should

import ebe/factorization/algorithm
import ebe/integer
import ebe/primality

pub fn main() {
  gleeunit.main()
}

pub fn run_pollard_rho_test() {
  8051
  |> algorithm.rho(seed: 2, func: fn(n) { n * n + 1 })
  |> algorithm.run
  |> should.be_some
  |> should.equal(97)

  10_403
  |> algorithm.rho(seed: 2, func: fn(n) { n * n + 1 })
  |> algorithm.run
  |> should.be_some
  |> should.equal(101)
}

pub fn find_divisor_test() {
  list.range(2, 2000)
  |> list.filter(fn(n) { n % 2 != 0 })
  |> list.filter(fn(n) { !primality.is_prime(n) })
  |> list.each(fn(number) {
    number
    |> algorithm.find_divisor
    |> should.be_some
    |> fn(divisor) {
      { 1 < divisor } |> should.be_true
      { divisor < number } |> should.be_true
      number |> integer.mod(divisor) |> should.equal(0)
    }
  })
}

pub fn run_pollard_minus_one_test() {
  299
  |> algorithm.minus_one(seed: 2)
  |> algorithm.run
  |> should.be_some
  |> should.equal(13)
}

pub fn run_williams_plus_one_test() {
  112_729
  |> algorithm.plus_one(seed: 5)
  |> algorithm.run
  |> should.be_some
  |> should.equal(139)

  112_729
  |> algorithm.plus_one(seed: 9)
  |> algorithm.run
  |> should.be_some
  |> should.equal(811)
}

pub fn run_fermat_test() {
  5959
  |> algorithm.fermat
  |> algorithm.run
  |> should.be_some
  |> should.equal(101)
}

pub fn run_trial_division_test() {
  [
    #(120, 2),
    #(121, 11),
    #(122, 2),
    #(123, 3),
    #(124, 2),
    #(125, 5),
    #(126, 2),
    #(127, 127),
    #(128, 2),
    #(129, 3),
    #(130, 2),
    #(131, 131),
    #(132, 2),
    #(133, 7),
    #(134, 2),
    #(135, 3),
    #(136, 2),
    #(137, 137),
    #(138, 2),
    #(139, 139),
    #(140, 2),
    #(141, 3),
    #(142, 2),
    #(143, 11),
    #(144, 2),
    #(145, 5),
    #(146, 2),
    #(147, 3),
    #(148, 2),
    #(149, 149),
  ]
  |> list.each(fn(tuple) {
    tuple.0
    |> algorithm.trial_division
    |> algorithm.run
    |> fn(res) {
      case tuple.0 == tuple.1 {
        True -> res |> should.be_none
        False ->
          res
          |> should.be_some
          |> should.equal(tuple.1)
      }
    }
  })
}
