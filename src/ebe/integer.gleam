//// Module containing basic integer functions

import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/pair
import gleam/result

/// Sign function
pub fn sgn(number: Int) -> Int {
  case int.compare(number, 0) {
    Eq -> 0
    Gt -> 1
    Lt -> -1
  }
}

/// Euclidean remainder
pub fn rem(dividend: Int, by divisor: Int) -> Result(Int, Nil) {
  case divisor == 0 {
    True -> Nil |> Error
    False -> {
      let remainder = dividend % divisor
      case remainder |> int.compare(0) {
        Lt -> divisor |> int.absolute_value |> int.add(remainder) |> Ok
        _ -> remainder |> Ok
      }
    }
  }
}

/// Euclidean division
pub fn div(dividend: Int, by divisor: Int) -> Result(Int, Nil) {
  dividend
  |> rem(divisor)
  |> result.map(fn(remainder) { { dividend - remainder } / divisor })
}

/// Euclidean division with remainder
pub fn div_rem(dividend: Int, by divisor: Int) -> Result(#(Int, Int), Nil) {
  dividend
  |> rem(divisor)
  |> result.map(fn(remainder) {
    #({ dividend - remainder } / divisor, remainder)
  })
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
      let assert Ok(#(quo, rem)) = div_rem(number, other)
      let next = #(prev.0 - quo * curr.0, prev.1 - quo * curr.1)
      bezout_loop(other, rem, curr, next)
    }
  }
}

/// Integer exponentiation
pub fn exp(number: Int, by exponent: Int) -> Int {
  case exponent {
    0 -> 1
    e if e % 2 == 0 -> exp(number * number, exponent / 2)
    _ -> number * exp(number * number, exponent / 2)
  }
}

/// Integer logarithm
pub fn log(number: Int, base: Int) -> Result(Int, Nil) {
  case number, base > 1 {
    0, True -> 0 |> Ok
    _, True -> log_loop(number |> int.absolute_value, base, 0) |> Ok
    _, _ -> Nil |> Error
  }
}

/// Integer logarithm - recursive function
/// Assumes base > 1
fn log_loop(number: Int, base: Int, exponent: Int) -> Int {
  case number < base {
    True -> exponent
    False -> log_loop(number / base, base, exponent + 1)
  }
}

/// p-adic representation
/// returns #(exp, n) such that number == n * base ^ exp
pub fn p_adic(number: Int, base: Int) -> Result(#(Int, Int), Nil) {
  case number, base > 1 {
    0, True -> #(0, 0) |> Ok
    _, True -> p_adic_loop(number |> int.absolute_value, base, 0) |> Ok
    _, _ -> Error(Nil)
  }
}

/// p-adic representation - recursive function
fn p_adic_loop(number: Int, base: Int, exponent: Int) -> #(Int, Int) {
  case number % base {
    0 -> p_adic_loop(number / base, base, exponent + 1)
    _ -> #(exponent, number)
  }
}
