//// Module containing basic integer functions

import gleam/float
import gleam/int
import gleam/list
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

/// Euclidean remainder
pub fn rem(number: Int, by divisor: Int) -> Result(Int, Nil) {
  case divisor == 0 {
    True -> Nil |> Error
    False -> number |> mod(by: divisor) |> Ok
  }
}

/// Euclidean remainder - unsafe
/// Assumes divisor != 0
pub fn mod(number: Int, by divisor: Int) -> Int {
  let remainder = number % divisor
  case remainder |> int.compare(0) {
    Lt -> divisor |> int.absolute_value |> int.add(remainder)
    _ -> remainder
  }
}

/// Euclidean quotient
pub fn quo(number: Int, by divisor: Int) -> Result(Int, Nil) {
  case divisor == 0 {
    True -> Nil |> Error
    False -> number |> div(by: divisor) |> Ok
  }
}

/// Euclidean quotient - unsafe
/// Assumes divisor != 0
pub fn div(number: Int, by divisor: Int) -> Int {
  number
  |> mod(by: divisor)
  |> fn(remainder) { { number - remainder } / divisor }
}

/// Euclidean division with remainder
pub fn quo_rem(number: Int, by divisor: Int) -> Result(#(Int, Int), Nil) {
  case divisor == 0 {
    True -> Nil |> Error
    False -> number |> div_mod(by: divisor) |> Ok
  }
}

/// Euclidean division with remainder - unsafe
/// Assumes divisor != 0
pub fn div_mod(number: Int, by divisor: Int) -> #(Int, Int) {
  number
  |> mod(divisor)
  |> fn(remainder) { #({ number - remainder } / divisor, remainder) }
}

/// Greatest common divisor
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
/// Returns #(x, y) such that number * x + other * y = gcd(number, other)
pub fn bezout(number: Int, other: Int) -> #(Int, Int) {
  case sgn(number), sgn(other) {
    0, s -> #(0, s)
    s, 0 -> #(s, 0)
    _, -1 ->
      bezout(number, other |> int.absolute_value) |> pair.map_second(int.negate)
    _, _ -> bezout_loop(number, other, #(1, 0), #(0, 1))
  }
}

/// Bezout - recursive function
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

/// Modular inverse
pub fn inv_mod(number: Int, mod modulus: Int) -> Result(Int, Nil) {
  case modulus > 1 {
    False -> Nil |> Error
    True -> {
      let inv = inv_mod_unsafe(number, modulus)
      case inv * number % modulus {
        1 -> inv |> Ok
        -1 -> inv |> Ok
        _ -> Nil |> Error
      }
    }
  }
}

/// Unsafe modular inverse without modulus check or invertibility check
pub fn inv_mod_unsafe(number: Int, mod modulus: Int) -> Int {
  let #(inv, _) = number |> bezout(modulus)
  case inv > 0 {
    True -> inv
    False -> inv + modulus
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

/// Modular exponentiation
pub fn exp_mod(
  number: Int,
  by exponent: Int,
  mod modulus: Int,
) -> Result(Int, Nil) {
  case modulus > 1, exponent < 0 {
    False, _ -> Nil |> Error
    True, False -> exp_mod_unsafe(number, exponent, modulus) |> Ok
    True, True -> exp_mod_unsafe(number, -exponent, modulus) |> inv_mod(modulus)
  }
}

/// Modular exponentiation without modulus check
pub fn exp_mod_unsafe(number: Int, by exponent: Int, mod modulus: Int) -> Int {
  case exponent < 0 {
    True ->
      number
      |> exp_mod_unsafe(by: -exponent, mod: modulus)
      |> inv_mod_unsafe(modulus)
    False ->
      case exponent {
        0 -> 1
        e if e % 2 == 0 ->
          exp_mod_unsafe(number * number % modulus, e / 2, modulus)
        _ ->
          {
            exp_mod_unsafe(number, exponent - 1, modulus)
            |> int.multiply(number)
          }
          % modulus
      }
  }
}

/// Integer logarithm
pub fn log(number: Int, base: Int) -> Result(Int, Nil) {
  case number >= 0, base > 1 {
    True, True -> log_unsafe(number, base) |> Ok
    _, _ -> Nil |> Error
  }
}

/// Integer logarithm - unsafe
/// Assumes number > 0 and base > 1
pub fn log_unsafe(number: Int, base: Int) -> Int {
  case number {
    0 -> 1
    _ -> log_loop(number, base, 0)
  }
}

/// Integer logarithm - recursive function
/// Assumes number > 0 and base > 1
fn log_loop(number: Int, base: Int, exponent: Int) -> Int {
  case number < base {
    True -> exponent
    False -> log_loop(number / base, base, exponent + 1)
  }
}

/// p-adic representation
/// returns #(exp, n) such that number == n * base ^ exp
pub fn p_adic(number: Int, base: Int) -> Result(#(Int, Int), Nil) {
  case base > 1 {
    True -> number |> p_adic_unsafe(base) |> Ok
    False -> Error(Nil)
  }
}

/// p-adic representation - unsafe
/// Assumes number base > 1
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

/// p-adic representation - recursive function
fn p_adic_loop(number: Int, base: Int, exponent: Int) -> #(Int, Int) {
  case number % base {
    0 -> p_adic_loop(number / base, base, exponent + 1)
    _ -> #(exponent, number)
  }
}

/// Legendre symbol - using Euler criterion 
/// Unsafe function - assumes prime is prime
pub fn legendre_symbol(number: Int, prime: Int) -> Int {
  case number % prime {
    0 -> 0
    _ ->
      case
        prime - 1 == exp_mod_unsafe(number, by: { prime - 1 } / 2, mod: prime)
      {
        True -> -1
        False -> 1
      }
  }
}

/// Jacobi symbol - generalization of Legendre symbol
pub fn jacobi_symbol(number: Int, other: Int) -> Result(Int, Nil) {
  case other % 2 {
    0 -> Nil |> Error
    _ -> number |> jacobi_symbol_unsafe(other) |> Ok
  }
}

/// Jacobi symbol - unsafe
/// Assumes other is odd
pub fn jacobi_symbol_unsafe(number: Int, other: Int) -> Int {
  case other {
    1 -> 1
    _ ->
      case gcd(number, other) {
        1 -> jacobi_symbol_loop(number, other, 1)
        _ -> 0
      }
  }
}

/// Jacobi symbol - recursive function
fn jacobi_symbol_loop(number: Int, other: Int, sign: Int) -> Int {
  case other {
    1 -> sign
    _ -> {
      let #(exp, rest) = p_adic_unsafe(number |> mod(other), 2)
      let sign = case exp % 2, rest % 4, other % 8 {
        0, 3, 3 -> -sign
        _, 3, 7 -> -sign
        1, 1, 3 -> -sign
        1, _, 5 -> -sign
        _, _, _ -> sign
      }
      jacobi_symbol_loop(other, rest, sign)
    }
  }
}

/// Integer square root
pub fn sqrt(number: Int) -> Result(Int, Nil) {
  case number < 0 {
    True -> Nil |> Error
    False -> number |> sqrt_unsafe |> Ok
  }
}

/// Integer square root - unsafe
/// Assumes number >= 0
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
pub fn is_square(number: Int) -> Bool {
  number >= 0
  && case number |> sqrt {
    Ok(s) -> s |> exp(by: 2) == number
    Error(Nil) -> False
  }
}
