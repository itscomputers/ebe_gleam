import ebe/integer
import gleam/int
import gleam/list
import gleam/order.{Lt}
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
}

/// Division test
pub fn div_test() {
  69 |> integer.div(7) |> should.equal(Ok(9))
  69 |> integer.div(-7) |> should.equal(Ok(-9))
  -69 |> integer.div(7) |> should.equal(Ok(-10))
  -69 |> integer.div(-7) |> should.equal(Ok(10))
}

/// Division with remainder test
pub fn div_rem_test() {
  let check_div_rem = fn(a: Int, b: Int) {
    let assert Ok(#(quo, rem)) = integer.div_rem(a, b)
    Ok(rem) |> should.equal(integer.rem(a, b))
    Ok(quo) |> should.equal(integer.div(a, b))
    rem |> int.compare(0) |> should.not_equal(Lt)
    rem |> int.compare(b |> int.absolute_value) |> should.equal(Lt)
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
  |> expand_examples_and_test(with: check_div_rem)
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

  let check_log = fn(tuple: #(Int, Int)) {
    let #(number, base) = tuple
    let assert Ok(exp) = integer.log(number, base)

    integer.exp(base, exp)
    |> int.compare(number)
    |> should.equal(Lt)

    integer.exp(base, exp + 1)
    |> int.compare(number)
    |> should.not_equal(Lt)
  }

  [#(57, 3), #(3982, 4), #(23_871, 5), #(60, 6), #(6, 2), #(99, 3), #(2398, 4)]
  |> list.each(check_log)
}

/// p-adic test
pub fn p_adic_test() {
  let check_p_adic = fn(tuple: #(Int, Int)) {
    let #(number, base) = tuple
    let assert Ok(#(exp, rem)) = integer.p_adic(number, base)
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
