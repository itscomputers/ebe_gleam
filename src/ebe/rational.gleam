//// Modular containing rational number functionality

import ebe/integer
import gleam/int
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result

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
    _ -> Rational(numerator, denominator) |> reduce |> Ok
  }
}

/// Construct new rational number - **unsafe**
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
pub fn compare(rational: Rational, with other: Rational) {
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
  case rational.numer |> int.compare(0) {
    Eq -> Error(Nil)
    Lt -> Rational(-rational.denom, -rational.numer) |> Ok
    Gt -> Rational(rational.denom, rational.numer) |> Ok
  }
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
  rational |> add(other |> negate)
}

/// Multiply two rational numbers
pub fn multiply(rational: Rational, by other: Rational) -> Rational {
  Rational(rational.numer * other.numer, rational.denom * other.denom) |> reduce
}

/// Divide a rational number by another rational number
pub fn divide(rational: Rational, by other: Rational) -> Result(Rational, Nil) {
  other |> reciprocal |> result.map(fn(other) { multiply(rational, other) })
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
    _ -> Rational(rational.numer, rational.denom * number) |> reduce |> Ok
  }
}

/// Floor division of rational number by an integer
pub fn floor_divide_int(rational: Rational, by number: Int) -> Result(Int, Nil) {
  rational |> divide_int(number) |> result.map(floor)
}

/// Reduce a rational number modulo an integer
pub fn modulo_int(rational: Rational, mod modulus: Int) -> Result(Rational, Nil) {
  case modulus |> int.compare(1) {
    Gt ->
      rational
      |> floor_divide_int(modulus)
      |> result.map(fn(floor) { rational |> subtract_int(floor * modulus) })
    _ -> Error(Nil)
  }
}

/// Floor
pub fn floor(rational: Rational) -> Int {
  case integer.div(rational.numer, rational.denom) {
    Ok(result) -> result
    _ -> panic
  }
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
  let sgn = integer.sgn(rational.denom)
  Rational(sgn * rational.numer / gcd, sgn * rational.denom / gcd)
}
