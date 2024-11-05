import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, Some}

import gleeunit
import gleeunit/should

import ebe/factorization.{type Factorization}
import ebe/primality

pub fn main() {
  gleeunit.main()
}

pub fn factor_test() {
  list.range(2, 1000)
  |> list.each(fn(number) {
    number
    |> factorization.factor
    |> assert_int(number)
    |> should.be_some
    |> factorization.to_dict
    |> dict.each(fn(prime, exp) {
      prime |> primality.is_prime |> should.be_true
      { exp > 0 } |> should.be_true
    })
  })
}

pub fn from_dict_test() {
  [#(2, 3), #(3, 1), #(5, 2)]
  |> dict.from_list
  |> factorization.from_dict
  |> assert_int(8 * 3 * 25)
}

pub fn exp_test() {
  [#(2, 3), #(3, 1), #(5, 2)]
  |> dict.from_list
  |> factorization.from_dict
  |> factorization.exp(2)
  |> assert_dict([#(2, 6), #(3, 2), #(5, 4)])
}

pub fn multiply_test() {
  [#(2, 3), #(3, 1), #(5, 2)]
  |> dict.from_list
  |> factorization.from_dict
  |> factorization.multiply(
    [#(2, 1), #(3, 2), #(7, 1)]
    |> dict.from_list
    |> factorization.from_dict,
  )
  |> assert_int(8 * 3 * 25 * 2 * 9 * 7)
  |> assert_dict([#(2, 4), #(3, 3), #(5, 2), #(7, 1)])
}

pub fn to_list_test() {
  [#(2, 3), #(3, 1), #(5, 2)]
  |> dict.from_list
  |> factorization.from_dict
  |> assert_list([2, 2, 2, 3, 5, 5])
}

fn assert_int(
  opt: Option(Factorization),
  expected: Int,
) -> Option(Factorization) {
  let f = opt |> should.be_some
  f |> factorization.to_int |> should.equal(expected)
  Some(f)
}

fn assert_dict(
  opt: Option(Factorization),
  expected: List(#(Int, Int)),
) -> Option(Factorization) {
  let f = opt |> should.be_some
  f |> factorization.to_dict |> should.equal(expected |> dict.from_list)
  Some(f)
}

fn assert_list(
  opt: Option(Factorization),
  expected: List(Int),
) -> Option(Factorization) {
  let f = opt |> should.be_some
  f
  |> factorization.to_list
  |> list.sort(by: int.compare)
  |> should.equal(
    expected
    |> list.sort(by: int.compare),
  )
  Some(f)
}
