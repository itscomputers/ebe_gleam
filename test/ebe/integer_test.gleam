import ebe/integer
import gleam/int
import gleam/list
import gleam/pair
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Remainder test
pub fn rem_test() {
  69 |> integer.rem(7) |> should.equal(Ok(6))
  69 |> integer.rem(-7) |> should.equal(Ok(6))
  -69 |> integer.rem(7) |> should.equal(Ok(1))
  -69 |> integer.rem(-7) |> should.equal(Ok(1))
  60 |> integer.rem(0) |> should.equal(Error(Nil))
}

/// Unsafe remainder test
pub fn mod_test() {
  69 |> integer.mod(7) |> should.equal(6)
  69 |> integer.mod(-7) |> should.equal(6)
  -69 |> integer.mod(7) |> should.equal(1)
  -69 |> integer.mod(-7) |> should.equal(1)
}

/// Quotient test
pub fn quo_test() {
  69 |> integer.quo(7) |> should.equal(Ok(9))
  69 |> integer.quo(-7) |> should.equal(Ok(-9))
  -69 |> integer.quo(7) |> should.equal(Ok(-10))
  -69 |> integer.quo(-7) |> should.equal(Ok(10))
  60 |> integer.quo(0) |> should.equal(Error(Nil))
}

/// Unsafe quotient test
pub fn div_test() {
  69 |> integer.div(7) |> should.equal(9)
  69 |> integer.div(-7) |> should.equal(-9)
  -69 |> integer.div(7) |> should.equal(-10)
  -69 |> integer.div(-7) |> should.equal(10)
}

/// Quotient with remainder test
pub fn quo_rem_test() {
  let check_quo_rem = fn(a: Int, b: Int) {
    let assert Ok(#(quo, rem)) = integer.quo_rem(a, b)
    Ok(quo) |> should.equal(integer.quo(a, b))
    Ok(rem) |> should.equal(integer.rem(a, b))
    { rem >= 0 } |> should.be_true
    { rem < int.absolute_value(b) } |> should.be_true
    b * quo + rem |> should.equal(a)
  }

  [
    #(69, 7),
    #(57, 66),
    #(3982, 6982),
    #(23_871, 69_584),
    #(60, 77),
    #(6, 4),
    #(99, 66),
    #(2398, 129),
  ]
  |> expand_examples_and_test(with: check_quo_rem)
}

/// Unsafe quotient with remainder test
pub fn div_mod_test() {
  let check_div_mod = fn(a: Int, b: Int) {
    let #(quo, rem) = integer.div_mod(a, b)
    quo |> should.equal(integer.div(a, b))
    rem |> should.equal(integer.mod(a, b))
    { rem >= 0 } |> should.be_true
    { rem < int.absolute_value(b) } |> should.be_true
    b * quo + rem |> should.equal(a)
  }

  [
    #(69, 7),
    #(57, 66),
    #(3982, 6982),
    #(23_871, 69_584),
    #(60, 77),
    #(6, 4),
    #(99, 66),
    #(2398, 129),
  ]
  |> expand_examples_and_test(with: check_div_mod)
}

/// Greatest common divisor test
pub fn gcd_test() {
  integer.gcd(0, 0) |> should.equal(0)

  let check_gcd = fn(a: Int, b: Int) {
    let d = integer.gcd(a, b)
    d |> int.absolute_value |> should.equal(d)
    a % d |> should.equal(0)
    b % d |> should.equal(0)
    integer.gcd(a / d, b / d) |> should.equal(1)
  }

  [
    #(69, 7),
    #(57, 66),
    #(3982, 6982),
    #(23_871, 69_584),
    #(60, 77),
    #(6, 4),
    #(99, 66),
    #(2398, 129),
  ]
  |> expand_examples_and_test(with: check_gcd)
}

/// Greatest common divisor list test
pub fn gcd_all_test() {
  [] |> integer.gcd_all |> should.equal(0)
  [0, 0, 0] |> integer.gcd_all |> should.equal(0)
  [-5] |> integer.gcd_all |> should.equal(5)

  let check_gcd_all = fn(numbers: List(Int)) {
    let d = integer.gcd_all(numbers)
    d |> int.absolute_value |> should.equal(d)
    numbers |> list.each(fn(number) { number % d |> should.equal(0) })
    numbers
    |> list.map(fn(number) { number / d })
    |> integer.gcd_all
    |> should.equal(1)
  }
  [
    [3982, 2981, 583, -3948, 19_238],
    [2, 3, 4, 5, 6, 7, 8, 9, 10],
    [60, 65, 70, 75, 80, 85, 90, 95],
  ]
  |> list.each(check_gcd_all)
}

/// Least common multiple test
pub fn lcm_test() {
  integer.lcm(0, 0) |> should.equal(0)

  let check_lcm = fn(a: Int, b: Int) {
    let m = integer.lcm(a, b)
    m |> int.absolute_value |> should.equal(m)
    m % a |> should.equal(0)
    m % b |> should.equal(0)
    a * b
    |> int.absolute_value
    |> should.equal(m * integer.gcd(a, b))
  }

  [
    #(69, 7),
    #(57, 66),
    #(3982, 6982),
    #(23_871, 69_584),
    #(60, 77),
    #(6, 4),
    #(99, 66),
    #(2398, 129),
  ]
  |> expand_examples_and_test(with: check_lcm)
}

/// Least common multiple list test
pub fn lcm_all_test() {
  [] |> integer.lcm_all |> should.equal(0)
  [0, 0, 0] |> integer.lcm_all |> should.equal(0)
  [-5] |> integer.lcm_all |> should.equal(5)

  let check_lcm_all = fn(numbers: List(Int)) {
    let m = integer.lcm_all(numbers)
    m |> int.absolute_value |> should.equal(m)
    numbers |> list.each(fn(number) { m % number |> should.equal(0) })
  }
  [
    [3982, 2981, 583, -3948, 19_238],
    [2, 3, 4, 5, 6, 7, 8, 9, 10],
    [60, 65, 70, 75, 80, 85, 90, 95],
  ]
  |> list.each(check_lcm_all)
}

/// Bezout's lemma test
pub fn bezout_test() {
  let check_bezout = fn(a: Int, b: Int) {
    let #(x, y) = integer.bezout(a, b)
    a * x + b * y |> should.equal(integer.gcd(a, b))
  }

  [
    #(0, 0),
    #(5, 0),
    #(0, 5),
    #(57, 66),
    #(3982, 6982),
    #(23_871, 69_584),
    #(60, 77),
    #(6, 4),
    #(99, 66),
    #(2398, 129),
  ]
  |> expand_examples_and_test(with: check_bezout)
}

/// Exponentiation test
pub fn exp_test() {
  integer.exp(5, 0) |> should.equal(1)
  integer.exp(5, 1) |> should.equal(5)
  integer.exp(5, 2) |> should.equal(25)
  integer.exp(5, 3) |> should.equal(125)
  integer.exp(5, 4) |> should.equal(625)
}

/// Integer logarithm test
pub fn log_test() {
  integer.log(8, 2) |> should.equal(Ok(3))
  integer.log(9, 2) |> should.equal(Ok(3))
  integer.log(15, 2) |> should.equal(Ok(3))
  integer.log(16, 2) |> should.equal(Ok(4))
  integer.log(0, 2) |> should.equal(Ok(1))
  integer.log(5, 1) |> should.equal(Error(Nil))
  integer.log(5, 0) |> should.equal(Error(Nil))
  integer.log(5, -3) |> should.equal(Error(Nil))

  let check_log = fn(tuple: #(Int, Int)) {
    let #(number, base) = tuple
    let assert Ok(exp) = integer.log(number, base)

    { integer.exp(base, exp) < number } |> should.be_true
    { integer.exp(base, exp + 1) >= number } |> should.be_true
  }

  [#(57, 3), #(3982, 4), #(23_871, 5), #(60, 6), #(6, 2), #(99, 3), #(2398, 4)]
  |> list.each(check_log)
}

/// Unsafe integer logarithm test
pub fn log_unsafe_test() {
  integer.log_unsafe(8, 2) |> should.equal(3)
  integer.log_unsafe(9, 2) |> should.equal(3)
  integer.log_unsafe(15, 2) |> should.equal(3)
  integer.log_unsafe(16, 2) |> should.equal(4)
  integer.log_unsafe(0, 2) |> should.equal(1)

  let check_log = fn(tuple: #(Int, Int)) {
    let #(number, base) = tuple
    let exp = integer.log_unsafe(number, base)

    { integer.exp(base, exp) < number } |> should.be_true
    { integer.exp(base, exp + 1) >= number } |> should.be_true
  }

  [#(57, 3), #(3982, 4), #(23_871, 5), #(60, 6), #(6, 2), #(99, 3), #(2398, 4)]
  |> list.each(check_log)
}

/// p-adic test
pub fn p_adic_test() {
  96 |> integer.p_adic(-5) |> should.equal(Error(Nil))
  96 |> integer.p_adic(0) |> should.equal(Error(Nil))
  96 |> integer.p_adic(1) |> should.equal(Error(Nil))
  96 |> integer.p_adic(2) |> should.equal(Ok(#(5, 3)))
  96 |> integer.p_adic(3) |> should.equal(Ok(#(1, 32)))
  96 |> integer.p_adic(4) |> should.equal(Ok(#(2, 6)))
  96 |> integer.p_adic(5) |> should.equal(Ok(#(0, 96)))
  96 |> integer.p_adic(6) |> should.equal(Ok(#(1, 16)))
  96 |> integer.p_adic(7) |> should.equal(Ok(#(0, 96)))
  96 |> integer.p_adic(8) |> should.equal(Ok(#(1, 12)))
  96 |> integer.p_adic(9) |> should.equal(Ok(#(0, 96)))
  96 |> integer.p_adic(10) |> should.equal(Ok(#(0, 96)))
  96 |> integer.p_adic(11) |> should.equal(Ok(#(0, 96)))
  96 |> integer.p_adic(12) |> should.equal(Ok(#(1, 8)))
}

/// Unsafe p-adic test
pub fn p_adic_unsafe_test() {
  let check_p_adic = fn(tuple: #(Int, Int)) {
    let #(number, base) = tuple
    let #(exp, rem) = integer.p_adic_unsafe(number, base)
    base |> integer.exp(exp) |> int.multiply(rem) |> should.equal(number)
  }

  [0, 1, 2, 15, 69, 420, 666, 1312]
  |> list.flat_map(fn(r) { [0, 1, 2, 3] |> list.map(fn(e) { #(e, r) }) })
  |> list.flat_map(fn(t) {
    [2, 3, 4, 5, 6] |> list.map(fn(b) { #(b, t.0, t.1) })
  })
  |> list.map(fn(t) { #(t.2 * integer.exp(t.0, t.1), t.0) })
  |> list.each(check_p_adic)
}

pub fn sqrt_test() {
  list.range(-100, 100)
  |> list.each(fn(number) {
    case number, number |> integer.sqrt {
      0, Ok(s) -> s |> should.equal(0)
      1, Ok(s) -> s |> should.equal(1)
      4, Ok(s) -> s |> should.equal(2)
      9, Ok(s) -> s |> should.equal(3)
      16, Ok(s) -> s |> should.equal(4)
      25, Ok(s) -> s |> should.equal(5)
      36, Ok(s) -> s |> should.equal(6)
      49, Ok(s) -> s |> should.equal(7)
      64, Ok(s) -> s |> should.equal(8)
      81, Ok(s) -> s |> should.equal(9)
      100, Ok(s) -> s |> should.equal(10)
      _, Ok(s) -> {
        { s * s < number } |> should.be_true
        { integer.exp(s + 1, 2) > number } |> should.be_true
      }
      _, Error(Nil) -> Nil
    }
  })
}

pub fn sqrt_unsafe_test() {
  list.range(-100, 100)
  |> list.each(fn(number) {
    integer.sqrt_unsafe(number * number)
    |> should.equal(number |> int.absolute_value)
  })
}

pub fn is_square_test() {
  list.range(-100, 100)
  |> list.each(fn(number) {
    case number {
      0 -> number |> integer.is_square |> should.be_true
      1 -> number |> integer.is_square |> should.be_true
      4 -> number |> integer.is_square |> should.be_true
      9 -> number |> integer.is_square |> should.be_true
      16 -> number |> integer.is_square |> should.be_true
      25 -> number |> integer.is_square |> should.be_true
      36 -> number |> integer.is_square |> should.be_true
      49 -> number |> integer.is_square |> should.be_true
      64 -> number |> integer.is_square |> should.be_true
      81 -> number |> integer.is_square |> should.be_true
      100 -> number |> integer.is_square |> should.be_true
      _ -> number |> integer.is_square |> should.be_false
    }
  })
}

/// Expand a list of tuples to include swaps and all possible neg/pos combinations
/// Then run the supplied test
fn expand_examples_and_test(
  tuples: List(#(Int, Int)),
  with function: fn(Int, Int) -> Nil,
) -> Nil {
  tuples
  |> list.flat_map(fn(t) { [t, pair.swap(t)] })
  |> list.flat_map(fn(t) { [t, #(-t.0, t.1), #(t.0, t.1), #(-t.0, -t.1)] })
  |> list.each(fn(t) { function(t.0, t.1) })
}
