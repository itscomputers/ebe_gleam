import ebe/rational.{type Rational}
import gleam/order.{Eq, Gt, Lt}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Constructor test
pub fn new_test() {
  rational.new(6, 7) |> assert_result_values(#(6, 7))
  rational.new(-6, 7) |> assert_result_values(#(-6, 7))
  rational.new(6, -7) |> assert_result_values(#(-6, 7))
  rational.new(-6, -7) |> assert_result_values(#(6, 7))

  rational.new(6, 8) |> assert_result_values(#(3, 4))
  rational.new(-6, 8) |> assert_result_values(#(-3, 4))
  rational.new(6, -8) |> assert_result_values(#(-3, 4))
  rational.new(-6, -8) |> assert_result_values(#(3, 4))

  rational.new(6, 9) |> assert_result_values(#(2, 3))
  rational.new(-6, 9) |> assert_result_values(#(-2, 3))
  rational.new(6, -9) |> assert_result_values(#(-2, 3))
  rational.new(-6, -9) |> assert_result_values(#(2, 3))

  rational.new(6, 6) |> assert_result_values(#(1, 1))
  rational.new(-6, 6) |> assert_result_values(#(-1, 1))
  rational.new(6, -6) |> assert_result_values(#(-1, 1))
  rational.new(-6, -6) |> assert_result_values(#(1, 1))

  rational.new(6, 2) |> assert_result_values(#(3, 1))
  rational.new(-6, 2) |> assert_result_values(#(-3, 1))
  rational.new(6, -2) |> assert_result_values(#(-3, 1))
  rational.new(-6, -2) |> assert_result_values(#(3, 1))

  rational.new(0, 2) |> assert_result_values(#(0, 1))
  rational.new(-0, 2) |> assert_result_values(#(0, 1))
  rational.new(0, -2) |> assert_result_values(#(0, 1))
  rational.new(-0, -2) |> assert_result_values(#(0, 1))

  rational.new(6, 0) |> should.equal(Error(Nil))
  rational.new(-6, 0) |> should.equal(Error(Nil))
}

/// Unsafe constructor test
pub fn frac_test() {
  rational.frac(6, 7) |> assert_values(#(6, 7))
  rational.frac(-6, 7) |> assert_values(#(-6, 7))
  rational.frac(6, -7) |> assert_values(#(-6, 7))
  rational.frac(-6, -7) |> assert_values(#(6, 7))

  rational.frac(6, 8) |> assert_values(#(3, 4))
  rational.frac(-6, 8) |> assert_values(#(-3, 4))
  rational.frac(6, -8) |> assert_values(#(-3, 4))
  rational.frac(-6, -8) |> assert_values(#(3, 4))

  rational.frac(6, 9) |> assert_values(#(2, 3))
  rational.frac(-6, 9) |> assert_values(#(-2, 3))
  rational.frac(6, -9) |> assert_values(#(-2, 3))
  rational.frac(-6, -9) |> assert_values(#(2, 3))

  rational.frac(6, 6) |> assert_values(#(1, 1))
  rational.frac(-6, 6) |> assert_values(#(-1, 1))
  rational.frac(6, -6) |> assert_values(#(-1, 1))
  rational.frac(-6, -6) |> assert_values(#(1, 1))

  rational.frac(6, 2) |> assert_values(#(3, 1))
  rational.frac(-6, 2) |> assert_values(#(-3, 1))
  rational.frac(6, -2) |> assert_values(#(-3, 1))
  rational.frac(-6, -2) |> assert_values(#(3, 1))

  rational.frac(0, 2) |> assert_values(#(0, 1))
  rational.frac(-0, 2) |> assert_values(#(0, 1))
  rational.frac(0, -2) |> assert_values(#(0, 1))
  rational.frac(-0, -2) |> assert_values(#(0, 1))
}

/// Construct from integer test
pub fn from_int_test() {
  rational.from_int(6) |> assert_values(#(6, 1))
  rational.from_int(-6) |> assert_values(#(-6, 1))
  rational.from_int(0) |> assert_values(#(0, 1))
}

/// Construct from pair test
pub fn from_pair_test() {
  rational.from_pair(#(6, 9)) |> assert_result_values(#(2, 3))
  rational.from_pair(#(-6, 9)) |> assert_result_values(#(-2, 3))
  rational.from_pair(#(6, -9)) |> assert_result_values(#(-2, 3))
  rational.from_pair(#(-6, -9)) |> assert_result_values(#(2, 3))
}

/// Comparison test
pub fn compare_test() {
  rational.frac(2, 3)
  |> rational.compare(rational.frac(3, 4))
  |> should.equal(Lt)

  rational.frac(-2, 3)
  |> rational.compare(rational.frac(-3, 4))
  |> should.equal(Gt)

  rational.frac(-2, 3)
  |> rational.compare(rational.frac(-6, 9))
  |> should.equal(Eq)
}

/// Approximately equal test
pub fn is_near_test() {
  let two_thirds = rational.frac(2, 3)
  let three_fourths = rational.frac(3, 4)

  two_thirds
  |> rational.is_near(to: three_fourths, within: rational.frac(1, 10))
  |> should.be_true

  two_thirds
  |> rational.is_near(to: three_fourths, within: rational.frac(1, 15))
  |> should.be_false
}

/// Negation test
pub fn negate_test() {
  rational.frac(6, 9) |> rational.negate |> assert_values(#(-2, 3))
  rational.frac(-6, 9) |> rational.negate |> assert_values(#(2, 3))
  rational.frac(6, -9) |> rational.negate |> assert_values(#(2, 3))
  rational.frac(-6, -9) |> rational.negate |> assert_values(#(-2, 3))
}

/// Absolute value test
pub fn abs_test() {
  rational.frac(6, 9) |> rational.abs |> assert_values(#(2, 3))
  rational.frac(-6, 9) |> rational.abs |> assert_values(#(2, 3))
  rational.frac(6, -9) |> rational.abs |> assert_values(#(2, 3))
  rational.frac(-6, -9) |> rational.abs |> assert_values(#(2, 3))
}

/// Reciprocoal test
pub fn reciprocal_test() {
  rational.frac(6, 9) |> rational.reciprocal |> assert_result_values(#(3, 2))
  rational.frac(-6, 9) |> rational.reciprocal |> assert_result_values(#(-3, 2))
  rational.frac(6, -9) |> rational.reciprocal |> assert_result_values(#(-3, 2))
  rational.frac(-6, -9) |> rational.reciprocal |> assert_result_values(#(3, 2))

  rational.frac(0, 6) |> rational.reciprocal |> should.equal(Error(Nil))
  rational.frac(0, -6) |> rational.reciprocal |> should.equal(Error(Nil))
}

/// Addition test
pub fn add_test() {
  rational.frac(1, 2)
  |> rational.add(rational.frac(1, 6))
  |> assert_values(#(2, 3))

  rational.frac(-1, 2)
  |> rational.add(rational.frac(1, 6))
  |> assert_values(#(-1, 3))

  rational.frac(1, 2)
  |> rational.add(rational.frac(-1, 6))
  |> assert_values(#(1, 3))

  rational.frac(-1, 2)
  |> rational.add(rational.frac(-1, 6))
  |> assert_values(#(-2, 3))
}

/// Subtraction test
pub fn subtract_test() {
  rational.frac(1, 2)
  |> rational.subtract(rational.frac(1, 6))
  |> assert_values(#(1, 3))

  rational.frac(-1, 2)
  |> rational.subtract(rational.frac(1, 6))
  |> assert_values(#(-2, 3))

  rational.frac(1, 2)
  |> rational.subtract(rational.frac(-1, 6))
  |> assert_values(#(2, 3))

  rational.frac(-1, 2)
  |> rational.subtract(rational.frac(-1, 6))
  |> assert_values(#(-1, 3))
}

/// Multiplication test
pub fn multiply_test() {
  rational.frac(3, 4)
  |> rational.multiply(rational.frac(2, 15))
  |> assert_values(#(1, 10))

  rational.frac(-3, 4)
  |> rational.multiply(rational.frac(2, 15))
  |> assert_values(#(-1, 10))

  rational.frac(3, 4)
  |> rational.multiply(rational.frac(-2, 15))
  |> assert_values(#(-1, 10))

  rational.frac(-3, 4)
  |> rational.multiply(rational.frac(-2, 15))
  |> assert_values(#(1, 10))
}

/// Division test
pub fn divide_test() {
  rational.frac(3, 4)
  |> rational.divide(rational.frac(15, 28))
  |> assert_result_values(#(7, 5))

  rational.frac(-3, 4)
  |> rational.divide(rational.frac(15, 28))
  |> assert_result_values(#(-7, 5))

  rational.frac(3, 4)
  |> rational.divide(rational.frac(-15, 28))
  |> assert_result_values(#(-7, 5))

  rational.frac(-3, 4)
  |> rational.divide(rational.frac(-15, 28))
  |> assert_result_values(#(7, 5))
}

/// Integer addition test
pub fn add_int_test() {
  rational.frac(6, 9) |> rational.add_int(5) |> assert_values(#(17, 3))
  rational.frac(-6, 9) |> rational.add_int(5) |> assert_values(#(13, 3))
  rational.frac(6, 9) |> rational.add_int(-5) |> assert_values(#(-13, 3))
  rational.frac(-6, 9) |> rational.add_int(-5) |> assert_values(#(-17, 3))
}

/// Integer subtraction test
pub fn subract_int_test() {
  rational.frac(6, 9) |> rational.subtract_int(5) |> assert_values(#(-13, 3))
  rational.frac(-6, 9) |> rational.subtract_int(5) |> assert_values(#(-17, 3))
  rational.frac(6, 9) |> rational.subtract_int(-5) |> assert_values(#(17, 3))
  rational.frac(-6, 9) |> rational.subtract_int(-5) |> assert_values(#(13, 3))
}

/// Integer multiplication test
pub fn multiply_int_test() {
  rational.frac(7, 9) |> rational.multiply_int(15) |> assert_values(#(35, 3))
  rational.frac(-7, 9) |> rational.multiply_int(15) |> assert_values(#(-35, 3))
  rational.frac(7, 9) |> rational.multiply_int(-15) |> assert_values(#(-35, 3))
  rational.frac(-7, 9) |> rational.multiply_int(-15) |> assert_values(#(35, 3))
}

/// Integer division test
pub fn divide_int_test() {
  rational.frac(10, 9)
  |> rational.divide_int(15)
  |> assert_result_values(#(2, 27))
  rational.frac(-10, 9)
  |> rational.divide_int(15)
  |> assert_result_values(#(-2, 27))
  rational.frac(10, 9)
  |> rational.divide_int(-15)
  |> assert_result_values(#(-2, 27))
  rational.frac(-10, 9)
  |> rational.divide_int(-15)
  |> assert_result_values(#(2, 27))
}

/// Integer floor division test
pub fn floor_divide_int_test() {
  rational.frac(420, 69)
  |> rational.floor_divide_int(4)
  |> should.equal(Ok(1))

  rational.frac(-420, 69)
  |> rational.floor_divide_int(4)
  |> should.equal(Ok(-2))
}

/// Integer modulo test
pub fn modulo_int_test() {
  rational.frac(420, 69)
  |> rational.modulo_int(2)
  |> assert_result_values(#(2, 23))
  rational.frac(-420, 69)
  |> rational.modulo_int(2)
  |> assert_result_values(#(44, 23))
}

/// Floor test
pub fn floor_test() {
  rational.frac(6, 9) |> rational.floor |> should.equal(0)
  rational.frac(66, 9) |> rational.floor |> should.equal(7)
  rational.frac(-6, 9) |> rational.floor |> should.equal(-1)
  rational.frac(-66, 9) |> rational.floor |> should.equal(-8)
  rational.frac(10, 2) |> rational.floor |> should.equal(5)
  rational.frac(-10, 2) |> rational.floor |> should.equal(-5)
  rational.frac(0, 6) |> rational.floor |> should.equal(0)
}

/// Ceiling test
pub fn ceil_test() {
  rational.frac(6, 9) |> rational.ceil |> should.equal(1)
  rational.frac(66, 9) |> rational.ceil |> should.equal(8)
  rational.frac(-6, 9) |> rational.ceil |> should.equal(0)
  rational.frac(-66, 9) |> rational.ceil |> should.equal(-7)
  rational.frac(10, 2) |> rational.ceil |> should.equal(5)
  rational.frac(-10, 2) |> rational.ceil |> should.equal(-5)
  rational.frac(0, 6) |> rational.ceil |> should.equal(0)
}

/// Rounding test
pub fn round_test() {
  rational.frac(6, 9) |> rational.round |> should.equal(1)
  rational.frac(4, 9) |> rational.round |> should.equal(0)
  rational.frac(15, 10) |> rational.round |> should.equal(2)
  rational.frac(66, 9) |> rational.round |> should.equal(7)
  rational.frac(68, 9) |> rational.round |> should.equal(8)
  rational.frac(75, 10) |> rational.round |> should.equal(8)
  rational.frac(-6, 9) |> rational.round |> should.equal(-1)
  rational.frac(-4, 9) |> rational.round |> should.equal(0)
  rational.frac(-15, 10) |> rational.round |> should.equal(-1)
  rational.frac(-66, 9) |> rational.round |> should.equal(-7)
  rational.frac(-68, 9) |> rational.round |> should.equal(-8)
  rational.frac(-75, 10) |> rational.round |> should.equal(-7)
  rational.frac(10, 2) |> rational.round |> should.equal(5)
  rational.frac(-10, 2) |> rational.round |> should.equal(-5)
  rational.frac(0, 6) |> rational.round |> should.equal(0)
}

/// Helper function to check values of a rational number
fn assert_values(r: Rational, tuple: #(Int, Int)) {
  r |> rational.numerator |> should.equal(tuple.0)
  r |> rational.denominator |> should.equal(tuple.1)
  r |> rational.to_pair |> should.equal(tuple)
}

/// Helper function to check values of a rational number result
fn assert_result_values(res: Result(Rational, Nil), tuple: #(Int, Int)) {
  let assert Ok(r) = res
  assert_values(r, tuple)
}
