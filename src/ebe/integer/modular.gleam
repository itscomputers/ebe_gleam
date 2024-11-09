//// Modulur arithmetic module
////    - most methods have a safe and an unsafe version
////    - unless otherwise specified, unsafe assumes modulus > 1

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/pair

import ebe/integer

/// Modular addition
pub fn add(number: Int, other: Int, mod modulus: Int) -> Option(Int) {
  modulus |> safe_binary(op: int.add, with: #(number, other))
}

/// Unsafe modular addition 
pub fn add_unsafe(number: Int, other: Int, mod modulus: Int) -> Int {
  modulus |> mod_binary(op: int.add, with: #(number, other))
}

/// Modular multiplication
pub fn multiply(number: Int, other: Int, mod modulus: Int) -> Option(Int) {
  modulus |> safe_binary(op: int.multiply, with: #(number, other))
}

/// Unsafe modular multiplication
pub fn multiply_unsafe(number: Int, other: Int, mod modulus: Int) -> Int {
  modulus |> mod_binary(op: int.multiply, with: #(number, other))
}

/// Modular negation
pub fn negate(number: Int, mod modulus: Int) -> Option(Int) {
  -number |> safe_mod(modulus)
}

/// Unsafe modular negation
pub fn negate_unsafe(number: Int, mod modulus: Int) -> Int {
  -number |> mod(modulus)
}

/// Modular inverse
pub fn inv(number: Int, mod modulus: Int) -> Option(Int) {
  number
  |> safe_mod(modulus)
  |> option.map(fn(number) {
    let inv = inv_unsafe(number, modulus)
    case multiply_unsafe(number, inv, modulus) {
      1 -> inv |> Some
      _ -> None
    }
  })
  |> option.flatten
}

/// Unsafe modular inverse 
/// Assumes modulus > 1 and number is invertible
pub fn inv_unsafe(number: Int, mod modulus: Int) -> Int {
  number
  |> integer.bezout(modulus)
  |> pair.first
  |> mod(modulus)
}

/// Modular exponentiation
pub fn exp(number: Int, by exponent: Int, mod modulus: Int) -> Option(Int) {
  case exponent < 0 {
    True ->
      exp(number, -exponent, modulus)
      |> option.map(fn(power) { inv(power, modulus) })
      |> option.flatten
    False ->
      number
      |> exp_unsafe(exponent, modulus)
      |> safe_mod(modulus)
  }
}

/// Unsafe modular exponentiation
/// Assumes modulus > 1 and exponent >= 0
pub fn exp_unsafe(number: Int, by exponent: Int, mod modulus: Int) -> Int {
  case exponent {
    0 -> 1
    e if e % 2 == 0 ->
      exp_unsafe(multiply_unsafe(number, number, modulus), e / 2, modulus)
    e -> multiply_unsafe(number, exp_unsafe(number, e - 1, modulus), modulus)
  }
}

/// Legendre symbol - using Euler criterion 
/// Unsafe function - assumes prime is prime
pub fn legendre_symbol(number: Int, prime: Int) -> Int {
  case number % prime {
    0 -> 0
    _ ->
      case prime - 1 == exp_unsafe(number, by: { prime - 1 } / 2, mod: prime) {
        True -> -1
        False -> 1
      }
  }
}

/// Jacobi symbol - generalization of Legendre symbol
pub fn jacobi_symbol(number: Int, other: Int) -> Option(Int) {
  case other > 0, other % 2 {
    False, _ | _, 0 -> None
    _, _ -> number |> jacobi_symbol_unsafe(other) |> Some
  }
}

/// Jacobi symbol - unsafe
/// Assumes other is positive and odd
pub fn jacobi_symbol_unsafe(number: Int, other: Int) -> Int {
  case other {
    1 -> 1
    _ ->
      case integer.gcd(number, other) {
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
      let #(exp, rest) = integer.p_adic_unsafe(number |> mod(other), 2)
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

/// Wrapper for unsafe remainder function
fn mod(number: Int, by modulus: Int) -> Int {
  number |> integer.mod(by: modulus)
}

/// Wrapper for remainder function
fn safe_mod(number: Int, by modulus: Int) -> Option(Int) {
  case modulus > 1 {
    True -> number |> mod(modulus) |> Some
    False -> None
  }
}

/// Safely call a modular function
fn safe_binary(
  modulus: Int,
  op operation: fn(Int, Int) -> Int,
  with values: #(Int, Int),
) -> Option(Int) {
  case modulus > 1 {
    True -> mod_binary(modulus, operation, values) |> Some
    False -> None
  }
}

/// Unsafely call a modular function
fn mod_binary(
  modulus: Int,
  op operation: fn(Int, Int) -> Int,
  with values: #(Int, Int),
) -> Int {
  values.0
  |> mod(modulus)
  |> operation(values.1 |> mod(modulus))
  |> mod(modulus)
}
