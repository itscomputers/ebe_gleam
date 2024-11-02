//// Lucas strong probable primality test
////    - uses Lucas sequences as witnesses to probable primality of a number
////    - assumes that the number is > 2 and odd
////    - a random witness will incorrectly observe a number as probably prime with
////      probability less than 4 / 15
////    - such numbers are called Lucas pseudoprimes of the witness sequence
////    - a list of random witnesses will incorrectly observe a number as probably prime
////      with probability less than (4 / 15) ^ witness_count

import gleam/list

import ebe/integer
import ebe/primality/observation.{
  type Observation, Composite, DivisorFound, Indeterminate, ProbablePrime,
  StrongProbablePrime, Undetermined,
}
import ebe/sequence/lucas.{type LucasSequence}

pub opaque type Witness {
  Witness(seq: LucasSequence, delta: Int, jacobi: Int, upper: Int, strong: Bool)
}

pub fn witness(p: Int, q: Int, number: Int) -> Witness {
  Witness(lucas.new_mod_unsafe(p, q, mod: number), 0, 0, 0, False)
}

/// Lucas strong probable prime observation
pub fn observation(number: Int, by witness: Witness) -> Observation {
  witness
  |> first_observation(number)
  |> fn(obs) {
    case obs |> observation.concrete {
      True -> obs
      False -> obs |> final_observation(witness, number)
    }
  }
}

fn first_observation(witness: Witness, number: Int) -> Observation {
  let divisors = number |> possible_divisors(witness.seq)
  Undetermined
  |> observation.combine(case
    divisors |> list.find(fn(value) { number == value })
  {
    Ok(_) -> Indeterminate
    Error(Nil) -> Undetermined
  })
  |> observation.combine(case
    divisors |> list.find(fn(value) { number > value })
  {
    Ok(divisor) -> DivisorFound(divisor)
    Error(Nil) -> Undetermined
  })
}

fn final_observation(
  obs: Observation,
  witness: Witness,
  number: Int,
) -> Observation {
  let witness = witness |> setup(number)
  let q = witness |> q_value
  let witness = witness |> double |> set_jacobi(number)
  obs
  |> observe_composite(witness, number, q, when: condition_u, or: Undetermined)
  |> observe_composite(witness, number, q, when: condition_v, or: Undetermined)
  |> observe_composite(witness, number, q, when: condition_q, or: ProbablePrime)
  |> apply_strong(witness)
}

fn setup(witness: Witness, number: Int) -> Witness {
  let seq = witness.seq
  let delta =
    number
    - {
      seq
      |> lucas.discriminant
      |> integer.jacobi_symbol_unsafe(number)
    }
  let #(upper, index) = delta |> integer.p_adic_unsafe(2)
  Witness(
    ..witness,
    seq: seq |> lucas.advance(by: index),
    delta: delta,
    upper: upper,
    strong: False,
  )
  |> set_strong
}

fn set_strong(witness: Witness) -> Witness {
  case witness.upper {
    1 -> witness
    _ ->
      witness
      |> double
      |> fn(witness) {
        Witness(
          ..witness,
          upper: witness.upper - 1,
          strong: witness.seq |> lucas.value |> fn(value) { value.v == 0 },
        )
      }
      |> set_strong
  }
}

fn set_jacobi(witness: Witness, number: Int) -> Witness {
  Witness(
    ..witness,
    jacobi: witness.seq
      |> lucas.q
      |> integer.jacobi_symbol_unsafe(number),
  )
}

fn possible_divisors(number: Int, seq: LucasSequence) -> List(Int) {
  [seq |> lucas.p, seq |> lucas.q, seq |> lucas.discriminant]
  |> list.map(fn(value) { integer.gcd(number, value) })
  |> list.filter(fn(value) { value > 1 })
}

fn double(witness: Witness) -> Witness {
  Witness(..witness, seq: witness.seq |> lucas.double)
}

fn condition_u(witness: Witness, _number: Int, _q: Int) -> Bool {
  { witness.seq |> lucas.value }.u != 0
}

fn condition_v(witness: Witness, number, _q: Int) -> Bool {
  let value = witness.seq |> lucas.value
  let q = witness.seq |> lucas.q
  witness.delta == number + 1 && value.v != { 2 * q } |> integer.mod(number)
}

fn condition_q(witness: Witness, number: Int, q: Int) -> Bool {
  let seq = witness.seq
  witness.delta == number + 1
  && q != { lucas.q(seq) * witness.jacobi } |> integer.mod(number)
  || witness.delta != number + 1
  && q != { witness.jacobi |> integer.mod(number) }
}

fn observe_composite(
  obs: Observation,
  witness: Witness,
  number: Int,
  q: Int,
  when condition: fn(Witness, Int, Int) -> Bool,
  or default: Observation,
) {
  case witness |> condition(number, q) {
    True -> Composite
    False -> obs |> observation.combine(default)
  }
}

fn apply_strong(obs: Observation, witness: Witness) -> Observation {
  case obs, witness.strong {
    ProbablePrime, True -> StrongProbablePrime
    _, _ -> obs
  }
}

fn q_value(witness: Witness) -> Int {
  { witness.seq |> lucas.value }.q
}
