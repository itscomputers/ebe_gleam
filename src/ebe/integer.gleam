//// Module containing basic integer functions

import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/pair

/// Sign function
pub fn sgn(number: Int) -> Int {
  case int.compare(number, 0) {
    Eq -> 0
    Gt -> 1
    Lt -> -1
  }
}

/// Euclidean division with remainder
///   returns #(quo, rem) such that
///     - number == divisor * quo + rem
///     - 0 <= rem < |divisor|
pub fn quo_rem(number: Int, by divisor: Int) -> Option(#(Int, Int)) {
  case divisor == 0 {
    True -> None
    False -> number |> div_mod(by: divisor) |> Some
  }
}

/// Unsafe Euclidean division with remainder
///   returns #(quo, rem) such that
///     - number == divisor * quo + rem
///     - 0 <= rem < |divisor|
///   assumes divisor != 0
pub fn div_mod(number: Int, by divisor: Int) -> #(Int, Int) {
  number
  |> mod(divisor)
  |> fn(remainder) { #({ number - remainder } / divisor, remainder) }
}

/// Euclidean remainder
pub fn rem(number: Int, by divisor: Int) -> Option(Int) {
  case divisor == 0 {
    True -> None
    False -> number |> mod(by: divisor) |> Some
  }
}

/// Unsafe Euclidean remainder
///   assumes divisor !=0
pub fn mod(number: Int, by divisor: Int) -> Int {
  let remainder = number % divisor
  case remainder |> int.compare(0) {
    Lt -> divisor |> int.absolute_value |> int.add(remainder)
    _ -> remainder
  }
}

/// Euclidean quotient
pub fn quo(number: Int, by divisor: Int) -> Option(Int) {
  case divisor == 0 {
    True -> None
    False -> number |> div(by: divisor) |> Some
  }
}

/// Unsafe Euclidean quotient
///   assumes divisor != 0
pub fn div(number: Int, by divisor: Int) -> Int {
  number
  |> mod(by: divisor)
  |> fn(remainder) { { number - remainder } / divisor }
}

/// Greatest common divisor
///   returns largest nonnegative integer that divides number, other
///     - gcd(0, 0) = 0 since 0 is the maximum with respect to divisibility
pub fn gcd(number: Int, with other: Int) -> Int {
  case other {
    0 -> number |> int.absolute_value
    _ -> gcd(other, number % other)
  }
}

/// Greatest common divisor of an integer list
pub fn gcd_all(numbers: List(Int)) -> Int {
  case numbers {
    [] -> 0
    [number] -> number |> int.absolute_value
    [first, ..rest] -> rest |> list.fold(from: first, with: gcd)
  }
}

/// Least common multiple
///   returns largest nonnegative integer that is multiple of number, other
pub fn lcm(number: Int, with other: Int) -> Int {
  case number, other {
    0, 0 -> 0
    _, _ -> { { number * other } |> int.absolute_value } / gcd(number, other)
  }
}

/// Least common multiple of an integer list
pub fn lcm_all(numbers: List(Int)) -> Int {
  case numbers {
    [] -> 0
    [number] -> number |> int.absolute_value
    [first, ..rest] -> rest |> list.fold(from: first, with: lcm)
  }
}

/// Bezout's lemma
///   returns #(x, y) such that number * x + other * y = gcd(number, other)
pub fn bezout(number: Int, other: Int) -> #(Int, Int) {
  case sgn(number), sgn(other) {
    0, s -> #(0, s)
    s, 0 -> #(s, 0)
    _, -1 ->
      bezout(number, other |> int.absolute_value) |> pair.map_second(int.negate)
    _, _ -> bezout_loop(number, other, #(1, 0), #(0, 1))
  }
}

fn bezout_loop(
  number: Int,
  other: Int,
  prev: #(Int, Int),
  curr: #(Int, Int),
) -> #(Int, Int) {
  case other |> int.compare(0) {
    Eq -> prev
    Lt -> panic
    Gt -> {
      let #(quo, rem) = div_mod(number, other)
      let next = #(prev.0 - quo * curr.0, prev.1 - quo * curr.1)
      bezout_loop(other, rem, curr, next)
    }
  }
}

/// Integer exponentiation
pub fn exp(number: Int, by exponent: Int) -> Int {
  case exponent {
    0 -> 1
    e if e % 2 == 0 -> exp(number * number, e / 2)
    _ -> number * exp(number * number, exponent / 2)
  }
}

/// Integer logarithm
///   returns largest exp such that base ^ exp <= number
pub fn log(number: Int, base: Int) -> Option(Int) {
  case number >= 0, base > 1 {
    True, True -> log_unsafe(number, base) |> Some
    _, _ -> None
  }
}

/// Unsafe integer logarithm
///   returns largest exp such that base ^ exp <= number
///   assumes number > 0 and base > 1
pub fn log_unsafe(number: Int, base: Int) -> Int {
  case number {
    0 -> 1
    _ -> log_loop(number, base, 0)
  }
}

fn log_loop(number: Int, base: Int, exponent: Int) -> Int {
  case number < base {
    True -> exponent
    False -> log_loop(number / base, base, exponent + 1)
  }
}

/// p-adic representation
///   returns #(exp, n) such that number == n * base ^ exp
pub fn p_adic(number: Int, base: Int) -> Option(#(Int, Int)) {
  case base > 1 {
    True -> number |> p_adic_unsafe(base) |> Some
    False -> None
  }
}

/// Unsafe p-adic representation
///   returns #(exp, n) such that number == n * base ^ exp
///   assumes number base > 1
pub fn p_adic_unsafe(number: Int, base: Int) -> #(Int, Int) {
  case number |> int.compare(0) {
    Eq -> #(0, 0)
    Lt ->
      number
      |> int.absolute_value
      |> p_adic_unsafe(base)
      |> fn(tuple) { #(tuple.0, -tuple.1) }
    Gt -> p_adic_loop(number, base, 0)
  }
}

fn p_adic_loop(number: Int, base: Int, exponent: Int) -> #(Int, Int) {
  case number % base {
    0 -> p_adic_loop(number / base, base, exponent + 1)
    _ -> #(exponent, number)
  }
}

/// Integer square root
///   returns largest root such that root ^ 2 <= number
pub fn sqrt(number: Int) -> Option(Int) {
  case number < 0 {
    True -> None
    False -> number |> sqrt_unsafe |> Some
  }
}

/// Unsafe integer square root
///   returns largest integer root such that root ^ 2 <= number
///   assumes number >= 0
pub fn sqrt_unsafe(number: Int) -> Int {
  let assert Ok(float_sqrt) = number |> int.square_root
  sqrt_loop(number, float_sqrt |> float.round)
}

fn sqrt_loop(number: Int, guess: Int) -> Int {
  let square = guess * guess
  case square > number || square + 2 * guess + 1 <= number {
    True -> sqrt_loop(number, { guess + number / guess } / 2)
    False -> guess
  }
}

/// Square property
///   returns True if number is a square, false otherwise
pub fn is_square(number: Int) -> Bool {
  number >= 0 && is_square_mod_16(number) && has_exact_sqrt(number)
}

fn is_square_mod_16(number: Int) -> Bool {
  case number % 16 {
    0 | 1 | 4 | 9 -> True
    _ -> False
  }
}

fn has_exact_sqrt(number: Int) -> Bool {
  case number |> sqrt {
    Some(s) -> s |> exp(by: 2) == number
    None -> False
  }
}

/// Nth-root
///   returns largest integer root such that root ^ degree <= number
pub fn root(number: Int, by degree: Int) -> Option(Int) {
  case degree |> int.compare(1) {
    Lt -> None
    Eq -> number |> Some
    Gt ->
      case number < 0, degree % 2 == 0 {
        True, True -> None
        True, False -> -root_unsafe(-number, degree) |> Some
        False, _ -> root_unsafe(number, degree) |> Some
      }
  }
}

/// Unsafe Nth-root
///   returns largest integer root such that root ^ degree <= number
///   assumes degree > 0 and number >= 0 if degree is even
pub fn root_unsafe(number: Int, by degree: Int) -> Int {
  root_loop(number, degree, number + 1, number)
}

fn root_loop(number: Int, degree: Int, prev: Int, curr: Int) -> Int {
  case prev > curr {
    True ->
      number |> root_loop(degree, curr, curr |> next_root_guess(number, degree))
    False -> prev
  }
}

fn next_root_guess(guess: Int, number: Int, degree: Int) -> Int {
  { { degree - 1 } * guess + number / { exp(guess, degree - 1) } } / degree
}
