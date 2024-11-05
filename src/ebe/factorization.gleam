//// Prime factorization module

import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}

import ebe/factorization/algorithm
import ebe/integer
import ebe/primality

pub opaque type Factorization {
  Factorization(number: Int, primes: Dict(Int, Int))
}

pub fn factor(number: Int) -> Option(Factorization) {
  case number < 2 {
    True -> None
    False ->
      case integer.p_adic_unsafe(number, 2) {
        #(e, 1) -> power_of_two(e)
        #(e, odd) -> odd |> factor_loop |> multiply(power_of_two(e))
      }
  }
}

fn factor_loop(number: Int) -> Option(Factorization) {
  case number == 1 {
    True -> new()
    False ->
      case number |> integer.is_square {
        True -> number |> integer.sqrt_unsafe |> factor_loop |> exp(2)
        False ->
          case number |> primality.is_prime {
            True -> number |> prime_factor
            False ->
              number
              |> algorithm.divisor
              |> option.map(factor_loop)
              |> option.flatten
              |> option.map(fn(f) {
                Some(f) |> multiply(factor_loop(number / f.number))
              })
              |> option.flatten
          }
      }
  }
}

pub fn to_int(f: Factorization) -> Int {
  f.number
}

pub fn to_dict(f: Factorization) -> Dict(Int, Int) {
  f.primes
}

pub fn to_list(f: Factorization) -> List(Int) {
  f.primes
  |> dict.fold(from: [], with: fn(acc, prime, exponent) {
    list.concat([acc, list.repeat(prime, times: exponent)])
  })
}

pub fn from_dict(dictionary: Dict(Int, Int)) -> Option(Factorization) {
  dictionary
  |> dict.fold(from: new(), with: fn(factorization, number, exponent) {
    factorization |> multiply(number |> factor |> exp(exponent))
  })
}

pub fn exp(opt: Option(Factorization), exponent: Int) -> Option(Factorization) {
  opt
  |> option.map(fn(f) {
    Factorization(
      number: integer.exp(f.number, exponent),
      primes: f.primes |> dict.map_values(fn(_, exp) { exp * exponent }),
    )
  })
}

pub fn multiply(
  opt1: Option(Factorization),
  opt2: Option(Factorization),
) -> Option(Factorization) {
  opt1
  |> option.map(fn(f1) {
    opt2
    |> option.map(fn(f2) {
      Factorization(
        number: f1.number * f2.number,
        primes: f1.primes |> dict.combine(f2.primes, int.add),
      )
    })
  })
  |> option.flatten
}

fn new() -> Option(Factorization) {
  Factorization(1, dict.new()) |> Some
}

fn power_of_two(exponent: Int) -> Option(Factorization) {
  case exponent {
    e if e < 0 -> None
    0 -> new()
    e -> 2 |> prime_factor |> exp(e)
  }
}

fn prime_factor(prime: Int) -> Option(Factorization) {
  Factorization(prime, [#(prime, 1)] |> dict.from_list) |> Some
}
