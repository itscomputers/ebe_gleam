//// Lucas sequence

import ebe/integer

/// Lucas sequence value
pub type LucasValue {
  LucasValue(index: Int, u: Int, v: Int, q: Int)
}

/// Lucas sequence parameters
type LucasParams {
  LucasParams(p: Int, q: Int)
  LucasModParams(p: Int, q: Int, modulus: Int)
}

/// Lucas sequence
pub opaque type LucasSequence {
  LucasSequence(curr: LucasValue, next: LucasValue, params: LucasParams)
}

/// Construct new Lucas sequence
pub fn new(p: Int, q: Int) {
  LucasSequence(
    curr: LucasValue(0, 0, 2, 1),
    next: LucasValue(1, 1, p, q),
    params: LucasParams(p, q),
  )
}

/// Construct new modular Lucas sequence
pub fn new_mod(p: Int, q: Int, mod modulus: Int) -> Result(LucasSequence, Nil) {
  case modulus > 1 {
    True -> new_mod_unsafe(p, q, modulus) |> Ok
    False -> Nil |> Error
  }
}

/// New modular Lucas sequence - unsafe
/// Assumes modulus > 1
pub fn new_mod_unsafe(p: Int, q: Int, mod modulus: Int) -> LucasSequence {
  LucasSequence(
    curr: LucasValue(0, 0, 2, 1),
    next: LucasValue(1, 1, p |> integer.mod(modulus), q |> integer.mod(modulus)),
    params: LucasModParams(p, q, modulus),
  )
}

/// Lucas sequence at an index
pub fn at(p: Int, q: Int, index index: Int) -> LucasSequence {
  new(p, q) |> advance(by: index)
}

/// Modular Lucas sequence at an index
pub fn mod_at(
  p: Int,
  q: Int,
  mod modulus: Int,
  index index: Int,
) -> Result(LucasSequence, Nil) {
  case modulus > 1 {
    True -> mod_at_unsafe(p, q, modulus, index) |> Ok
    False -> Nil |> Error
  }
}

/// Modular Lucas sequence at an index - unsafe
/// Assumes modulus > 1
pub fn mod_at_unsafe(
  p: Int,
  q: Int,
  mod modulus: Int,
  index index: Int,
) -> LucasSequence {
  new_mod_unsafe(p, q, modulus) |> advance(by: index)
}

/// Current value of Lucas sequence
pub fn value(seq: LucasSequence) -> LucasValue {
  seq.curr
}

/// P-value of Lucas sequence
pub fn p(seq: LucasSequence) -> Int {
  seq.params.p
}

/// Q-value of Lucas sequence
pub fn q(seq: LucasSequence) -> Int {
  seq.params.q
}

/// 
/// Discriminant of Lucas sequence
pub fn discriminant(seq: LucasSequence) -> Int {
  seq.params.p * seq.params.p - 4 * seq.params.q
}

/// Next step of Lucas sequence
pub fn next(seq: LucasSequence) -> LucasSequence {
  LucasSequence(..seq, curr: seq.next, next: seq |> next_value)
  |> reduce
}

/// Double index of Lucas sequence
pub fn double(seq: LucasSequence) -> LucasSequence {
  LucasSequence(..seq, curr: seq |> double_curr, next: seq |> double_next)
  |> reduce
}

pub fn advance(seq: LucasSequence, by index: Int) -> LucasSequence {
  case index {
    0 -> seq
    idx if idx % 2 == 1 -> seq |> advance(idx - 1) |> next
    _ -> seq |> advance(index / 2) |> double
  }
}

/// Next value of Lucas sequence
fn next_value(seq: LucasSequence) -> LucasValue {
  LucasValue(
    index: seq.next.index + 1,
    u: seq.next.u * seq.params.p - seq.curr.u * seq.params.q,
    v: seq.next.v * seq.params.p - seq.curr.v * seq.params.q,
    q: seq.next.q * seq.params.q,
  )
}

/// Double index of current value of Lucas sequence
fn double_curr(seq: LucasSequence) -> LucasValue {
  LucasValue(
    index: 2 * seq.curr.index,
    u: seq.curr.u * seq.curr.v,
    v: seq.curr.v * seq.curr.v - 2 * seq.curr.q,
    q: seq.curr.q * seq.curr.q,
  )
}

/// Double index of next value of Lucas sequence
fn double_next(seq: LucasSequence) -> LucasValue {
  LucasValue(
    index: 2 * seq.next.index - 1,
    u: seq.next.u * seq.curr.v - seq.curr.q,
    v: seq.next.v * seq.curr.v - seq.curr.q * seq.params.p,
    q: seq.curr.q * seq.curr.q * seq.params.q,
  )
}

/// Reduce Lucas sequence by its modulus, if present
fn reduce(seq: LucasSequence) -> LucasSequence {
  case seq.params {
    LucasParams(_, _) -> seq
    LucasModParams(_, _, modulus) ->
      LucasSequence(
        ..seq,
        curr: seq.curr |> reduce_value(mod: modulus),
        next: seq.next |> reduce_value(mod: modulus),
      )
  }
}

/// Reduce Lucas value by a modulus
fn reduce_value(value: LucasValue, mod modulus: Int) -> LucasValue {
  LucasValue(
    ..value,
    u: value.u |> integer.mod(modulus),
    v: value.v |> integer.mod(modulus),
    q: value.q |> integer.mod(modulus),
  )
}
