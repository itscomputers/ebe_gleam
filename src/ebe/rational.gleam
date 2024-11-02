//// Modular containing rational number functionality

import ebe/integer
import gleam/int
import gleam/order.{type Order, Lt}

/// Rational type
pub opaque type Rational {
  Rational(numer: Int, denom: Int)
}

/// Construct new rational number
pub fn new(
  numer numerator: Int,
  denom denominator: Int,
) -> Result(Rational, Nil) {
  case denominator {
    0 -> Error(Nil)
    _ -> frac(numerator, denominator) |> Ok
  }
}

/// Unsafely construct new rational number
/// Assumes denominator != 0
pub fn frac(numerator: Int, denominator: Int) {
  case denominator {
    0 -> panic
    _ -> Rational(numerator, denominator) |> reduce
  }
}

/// Construct rational number from an integer
pub fn from_int(number: Int) -> Rational {
  Rational(number, 1)
}

/// Construct from pair of integers
pub fn from_pair(tuple: #(Int, Int)) -> Result(Rational, Nil) {
  new(tuple.0, tuple.1)
}

/// Convert to pair
pub fn to_pair(rational: Rational) -> #(Int, Int) {
  #(rational.numer, rational.denom)
}

/// Get numerator of rational number
pub fn numerator(rational: Rational) -> Int {
  rational.numer
}

/// Get denominator of rational number
pub fn denominator(rational: Rational) -> Int {
  rational.denom
}

/// Compare two rational numbers
pub fn compare(rational: Rational, with other: Rational) -> Order {
  int.compare(rational.numer * other.denom, rational.denom * other.numer)
}

/// Determine if two rational numbers are within a threshold distance
pub fn is_near(
  rational: Rational,
  to other: Rational,
  within threshold: Rational,
) -> Bool {
  case rational |> subtract(other) |> abs |> compare(threshold |> abs) {
    Lt -> True
    _ -> False
  }
}

/// Negate rational number
pub fn negate(rational: Rational) -> Rational {
  Rational(-rational.numer, rational.denom)
}

/// Absolute value
pub fn abs(rational: Rational) -> Rational {
  Rational(rational.numer |> int.absolute_value, rational.denom)
}

/// Build reciprocal of a rational number
pub fn reciprocal(rational: Rational) -> Result(Rational, Nil) {
  case rational.numer == 0 {
    True -> Error(Nil)
    False -> rational |> reciprocal_unsafe |> Ok
  }
}

/// Reciprocal - unsafe
/// Assumes rational number is nonzero
pub fn reciprocal_unsafe(rational: Rational) -> Rational {
  Rational(rational.denom, rational.numer) |> reduce_sign
}

/// Add two rational numbers
pub fn add(rational: Rational, with other: Rational) -> Rational {
  Rational(
    rational.numer * other.denom + rational.denom * other.numer,
    rational.denom * other.denom,
  )
  |> reduce
}

/// Subtract another rational number from a rational number
pub fn subtract(rational: Rational, other: Rational) -> Rational {
  other |> negate |> add(rational)
}

/// Multiply two rational numbers
pub fn multiply(rational: Rational, by other: Rational) -> Rational {
  Rational(rational.numer * other.numer, rational.denom * other.denom) |> reduce
}

/// Divide a rational number by another rational number
pub fn divide(rational: Rational, by other: Rational) -> Result(Rational, Nil) {
  case other.numer == 0 {
    True -> Nil |> Error
    False -> rational |> divide_unsafe(by: other) |> Ok
  }
}

/// Divide - unsafe
/// Assumes other is nonzero
pub fn divide_unsafe(rational: Rational, by other: Rational) -> Rational {
  other |> reciprocal_unsafe |> multiply(rational)
}

/// Compare rational number to integer
pub fn compare_int(rational: Rational, with number: Int) -> Order {
  rational |> compare(number |> from_int)
}

/// Add a rational number and an integer
pub fn add_int(rational: Rational, with number: Int) -> Rational {
  Rational(rational.numer + rational.denom * number, rational.denom)
}

/// Subtract an integer from a rational number
pub fn subtract_int(rational: Rational, number: Int) -> Rational {
  rational |> add_int(-number)
}

/// Multiply a rational number by an integer
pub fn multiply_int(rational: Rational, by number: Int) -> Rational {
  Rational(rational.numer * number, rational.denom) |> reduce
}

/// Divide a rational number by an integer
pub fn divide_int(rational: Rational, by number: Int) -> Result(Rational, Nil) {
  case number {
    0 -> Error(Nil)
    _ -> rational |> divide_int_unsafe(by: number) |> Ok
  }
}

/// Divide by an integer - unsafe
/// Assumes number nonzero
pub fn divide_int_unsafe(rational: Rational, by number: Int) -> Rational {
  Rational(rational.numer, rational.denom * number) |> reduce
}

/// Floor division of rational number by an integer
pub fn floor_divide_int(rational: Rational, by number: Int) -> Result(Int, Nil) {
  case number == 0 {
    True -> Nil |> Error
    False -> rational |> floor_divide_int_unsafe(by: number) |> Ok
  }
}

/// Floor division by an integer - unsafe
/// Assumes number nonzero
pub fn floor_divide_int_unsafe(rational: Rational, by number: Int) -> Int {
  rational |> divide_int_unsafe(by: number) |> floor
}

/// Reduce a rational number modulo an integer
pub fn modulo_int(rational: Rational, mod modulus: Int) -> Result(Rational, Nil) {
  case modulus > 1 {
    True -> rational |> modulo_int_unsafe(mod: modulus) |> Ok
    False -> Error(Nil)
  }
}

/// Reduce modulo an integer - unsafe
/// Assumes modulus is > 1
pub fn modulo_int_unsafe(rational: Rational, mod modulus: Int) -> Rational {
  rational
  |> floor_divide_int_unsafe(modulus)
  |> fn(floor) { rational |> subtract_int(floor * modulus) }
}

/// Floor
pub fn floor(rational: Rational) -> Int {
  integer.div(rational.numer, rational.denom)
}

/// Ceiling
pub fn ceil(rational: Rational) -> Int {
  case rational.denom {
    1 -> rational.numer
    _ -> floor(rational) + 1
  }
}

/// Round
pub fn round(rational: Rational) -> Int {
  rational |> add(Rational(1, 2)) |> floor
}

/// Convert a rational number into reduced form
fn reduce(rational: Rational) -> Rational {
  let gcd = integer.gcd(rational.numer, rational.denom)
  Rational(rational.numer / gcd, rational.denom / gcd) |> reduce_sign
}

/// Convert a rational number to have positive denominator
fn reduce_sign(rational: Rational) -> Rational {
  let sgn = integer.sgn(rational.denom)
  Rational(sgn * rational.numer, sgn * rational.denom)
}
