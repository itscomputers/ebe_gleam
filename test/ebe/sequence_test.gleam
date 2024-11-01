import gleam/list
import gleeunit
import gleeunit/should

import ebe/integer
import ebe/sequence/lucas.{type LucasSequence, type LucasValue, LucasValue}

pub fn main() {
  gleeunit.main()
}

pub fn lucas_test() {
  lucas.new(1, -1)
  |> lucas.next
  |> check_value(LucasValue(1, 1, 1, -1))
  |> lucas.next
  |> check_value(LucasValue(2, 1, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(3, 2, 4, -1))
  |> lucas.next
  |> check_value(LucasValue(4, 3, 7, 1))
  |> lucas.next
  |> check_value(LucasValue(5, 5, 11, -1))
  |> lucas.next
  |> check_value(LucasValue(6, 8, 18, 1))
  |> lucas.next
  |> check_value(LucasValue(7, 13, 29, -1))
  |> lucas.next
  |> check_value(LucasValue(8, 21, 47, 1))
  |> lucas.next
  |> check_value(LucasValue(9, 34, 76, -1))
  |> lucas.next
  |> check_value(LucasValue(10, 55, 123, 1))
}

pub fn lucas_at_test() {
  initial_values()
  |> list.index_map(fn(value, idx) {
    lucas.at(1, -1, idx) |> lucas.value |> should.equal(value)
  })
}

pub fn lucas_double_test() {
  lucas.new(1, -1)
  |> lucas.next
  |> check_value(LucasValue(1, 1, 1, -1))
  |> lucas.double
  |> check_value(LucasValue(2, 1, 3, 1))
  |> lucas.double
  |> check_value(LucasValue(4, 3, 7, 1))
  |> lucas.double
  |> check_value(LucasValue(8, 21, 47, 1))
  |> lucas.double
  |> check_value(LucasValue(16, 987, 2207, 1))
  |> lucas.double
  |> check_value(LucasValue(32, 2_178_309, 4_870_847, 1))
  |> lucas.double
  |> check_value(LucasValue(64, 10_610_209_857_723, 23_725_150_497_407, 1))
}

pub fn lucas_double_then_next_test() {
  lucas.new(1, -1)
  |> lucas.next
  |> check_value(LucasValue(1, 1, 1, -1))
  |> lucas.double
  |> check_value(LucasValue(2, 1, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(3, 2, 4, -1))
  |> lucas.double
  |> check_value(LucasValue(6, 8, 18, 1))
  |> lucas.next
  |> check_value(LucasValue(7, 13, 29, -1))
  |> lucas.double
  |> check_value(LucasValue(14, 377, 843, 1))
  |> lucas.next
  |> check_value(LucasValue(15, 610, 1364, -1))
  |> lucas.double
  |> check_value(LucasValue(30, 832_040, 1_860_498, 1))
  |> lucas.next
  |> check_value(LucasValue(31, 1_346_269, 3_010_349, -1))
}

pub fn lucas_mod_test() {
  lucas.new_mod_unsafe(1, -1, 5)
  |> check_value(LucasValue(0, 0, 2, 1))
  |> lucas.next
  |> check_value(LucasValue(1, 1, 1, 4))
  |> lucas.next
  |> check_value(LucasValue(2, 1, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(3, 2, 4, 4))
  |> lucas.next
  |> check_value(LucasValue(4, 3, 2, 1))
  |> lucas.next
  |> check_value(LucasValue(5, 0, 1, 4))
  |> lucas.next
  |> check_value(LucasValue(6, 3, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(7, 3, 4, 4))
  |> lucas.next
  |> check_value(LucasValue(8, 1, 2, 1))
  |> lucas.next
  |> check_value(LucasValue(9, 4, 1, 4))
  |> lucas.next
  |> check_value(LucasValue(10, 0, 3, 1))
}

pub fn lucas_mod_at_test() {
  let modulus = 5
  initial_mod_values(modulus)
  |> list.index_map(fn(value, idx) {
    lucas.mod_at_unsafe(1, -1, idx, mod: modulus)
    |> lucas.value
    |> should.equal(value)
  })
}

pub fn lucas_mod_double_test() {
  lucas.new_mod_unsafe(1, -1, 5)
  |> lucas.next
  |> check_value(LucasValue(1, 1, 1, 4))
  |> lucas.double
  |> check_value(LucasValue(2, 1, 3, 1))
  |> lucas.double
  |> check_value(LucasValue(4, 3, 2, 1))
  |> lucas.double
  |> check_value(LucasValue(8, 1, 2, 1))
  |> lucas.double
  |> check_value(LucasValue(16, 2, 2, 1))
  |> lucas.double
  |> check_value(LucasValue(32, 4, 2, 1))
  |> lucas.double
  |> check_value(LucasValue(64, 3, 2, 1))
}

pub fn lucas_mod_double_then_next_test() {
  lucas.new_mod_unsafe(1, -1, 5)
  |> lucas.next
  |> check_value(LucasValue(1, 1, 1, 4))
  |> lucas.double
  |> check_value(LucasValue(2, 1, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(3, 2, 4, 4))
  |> lucas.double
  |> check_value(LucasValue(6, 3, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(7, 3, 4, 4))
  |> lucas.double
  |> check_value(LucasValue(14, 2, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(15, 0, 4, 4))
  |> lucas.double
  |> check_value(LucasValue(30, 0, 3, 1))
  |> lucas.next
  |> check_value(LucasValue(31, 4, 4, 4))
}

fn check_value(seq: LucasSequence, expected: LucasValue) -> LucasSequence {
  seq |> lucas.value |> should.equal(expected)
  seq
}

fn initial_values() -> List(LucasValue) {
  [
    LucasValue(0, 0, 2, 1),
    LucasValue(1, 1, 1, -1),
    LucasValue(2, 1, 3, 1),
    LucasValue(3, 2, 4, -1),
    LucasValue(4, 3, 7, 1),
    LucasValue(5, 5, 11, -1),
    LucasValue(6, 8, 18, 1),
    LucasValue(7, 13, 29, -1),
    LucasValue(8, 21, 47, 1),
    LucasValue(9, 34, 76, -1),
    LucasValue(10, 55, 123, 1),
  ]
}

fn initial_mod_values(mod modulus: Int) -> List(LucasValue) {
  initial_values()
  |> list.map(fn(value) {
    LucasValue(
      ..value,
      u: value.u |> integer.mod(modulus),
      v: value.v |> integer.mod(modulus),
      q: value.q |> integer.mod(modulus),
    )
  })
}
