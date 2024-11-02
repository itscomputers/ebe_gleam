//// Lucas strong probable primality test
////    - uses Lucas sequences as witnesses to probable primality of a number
////    - assumes that the number is > 2 and odd
////    - a random witness will incorrectly observe a number as probably prime with
////      probability less than 4 / 15
////    - such numbers are called Lucas pseudoprimes of the witness sequence
////    - a list of random witnesses will incorrectly observe a number as probably prime
////      with probability less than (4 / 15) ^ witness_count

import gleam/iterator.{type Iterator}
import gleam/list

import ebe/integer
import ebe/primality/observation.{
  type Observation, Composite, DivisorFound, Indeterminate, ProbablePrime,
  StrongProbablePrime, Undetermined,
}
import ebe/sequence/lucas.{type LucasSequence}

/// Witness for observed primality
pub opaque type Witness {
  Witness(seq: LucasSequence, delta: Int, jacobi: Int, upper: Int, strong: Bool)
}

pub fn observe_random(number: Int, count witness_count: Int) -> Observation {
  number
  |> observe(
    by: witnesses(number)
    |> iterator.take(witness_count)
    |> iterator.to_list
    |> list.map(fn(search) { search.witness }),
  )
}

pub fn observe(number: Int, by witnesses: List(Witness)) -> Observation {
  Undetermined |> observe_loop(number, witnesses)
}

/// Combined observation - recursive method
fn observe_loop(
  obs: Observation,
  number: Int,
  witnesses: List(Witness),
) -> Observation {
  case witnesses {
    [] -> obs
    [witness, ..rest] ->
      obs
      |> observation.combine_lazy(fn() { number |> observation(by: witness) })
      |> observe_loop(number, rest)
  }
}

/// Construct a witness for primality of number using Lucas values p, q
pub fn witness(p: Int, q: Int, number: Int) -> Witness {
  Witness(lucas.new_mod_unsafe(p, q, mod: number), 0, 0, 0, False)
}

/// Lucas strong probable prime observation
pub fn observation(number: Int, by witness: Witness) -> Observation {
  witness
  |> first_observation(number)
  |> observation.combine_lazy(fn() { witness |> lucas_observation(number) })
}

/// Early observation of two extreme cases:
///   - Indeterminate if the witness will not work for number
///   - DivisorFound if the witness stumbled upon a divisor of number
fn first_observation(witness: Witness, number: Int) -> Observation {
  let divisors = number |> possible_divisors(witness.seq)
  Undetermined
  |> observation.combine_lazy(fn() {
    case divisors |> list.find(fn(value) { number == value }) {
      Ok(_) -> Indeterminate
      Error(Nil) -> Undetermined
    }
  })
  |> observation.combine_lazy(fn() {
    case divisors |> list.find(fn(value) { number > value }) {
      Ok(divisor) -> DivisorFound(divisor)
      Error(Nil) -> Undetermined
    }
  })
}

/// Primary observation of primality of number by witness
fn lucas_observation(witness: Witness, number: Int) -> Observation {
  let witness = witness |> setup(number)
  let q = witness |> q_value
  let witness = witness |> double |> set_jacobi(number)
  Undetermined
  |> observe_composite(witness, number, q, when: condition_u, or: Undetermined)
  |> observe_composite(witness, number, q, when: condition_v, or: Undetermined)
  |> observe_composite(witness, number, q, when: condition_q, or: ProbablePrime)
  |> apply_strong(witness)
}

/// Prepare the witness for observation
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

/// Set strong attribute based on the intermediate state of algorithm
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

/// Set jacobi symbol for use with composite conditions
fn set_jacobi(witness: Witness, number: Int) -> Witness {
  Witness(
    ..witness,
    jacobi: witness.seq
      |> lucas.q
      |> integer.jacobi_symbol_unsafe(number),
  )
}

/// List of possible divisors of number from the sequence
fn possible_divisors(number: Int, seq: LucasSequence) -> List(Int) {
  [seq |> lucas.p, seq |> lucas.q, seq |> lucas.discriminant]
  |> list.map(fn(value) { integer.gcd(number, value) })
  |> list.filter(fn(value) { value > 1 })
}

/// Double the index of the witness Lucas sequence
fn double(witness: Witness) -> Witness {
  Witness(..witness, seq: witness.seq |> lucas.double)
}

/// Composite condition based on the Lucas U-value
fn condition_u(witness: Witness, _number: Int, _q: Int) -> Bool {
  { witness.seq |> lucas.value }.u != 0
}

/// Composite condition based on the Lucas V-value
fn condition_v(witness: Witness, number, _q: Int) -> Bool {
  let value = witness.seq |> lucas.value
  let q = witness.seq |> lucas.q
  witness.delta == number + 1 && value.v != { 2 * q } |> integer.mod(number)
}

/// Composite condition based on the Lucas Q-value
fn condition_q(witness: Witness, number: Int, q: Int) -> Bool {
  let seq = witness.seq
  witness.delta == number + 1
  && q != { lucas.q(seq) * witness.jacobi } |> integer.mod(number)
  || witness.delta != number + 1
  && q != { witness.jacobi |> integer.mod(number) }
}

/// Composite observation using composite condition with a default fallback
fn observe_composite(
  obs: Observation,
  witness: Witness,
  number: Int,
  q: Int,
  when condition: fn(Witness, Int, Int) -> Bool,
  or default: Observation,
) {
  obs
  |> observation.combine_lazy(fn() {
    case witness |> condition(number, q) {
      True -> Composite
      False -> default
    }
  })
}

/// Apply strong attribute to an observation
fn apply_strong(obs: Observation, witness: Witness) -> Observation {
  case obs, witness.strong {
    ProbablePrime, True -> StrongProbablePrime
    _, _ -> obs
  }
}

/// Extract Lucas Q-value from witness
fn q_value(witness: Witness) -> Int {
  { witness.seq |> lucas.value }.q
}

type WitnessSearch {
  WitnessSearch(number: Int, discriminant: Int, witness: Witness)
}

fn witnesses(number: Int) -> Iterator(WitnessSearch) {
  iterator.iterate(witness_search(number, 5), next_search)
  |> iterator.filter(fn(search) {
    search.discriminant |> integer.jacobi_symbol_unsafe(search.number) == -1
  })
}

fn next_search(search: WitnessSearch) -> WitnessSearch {
  let sgn = search.discriminant |> integer.sgn
  let discriminant = { search.discriminant + 2 * sgn } * sgn
  witness_search(search.number, discriminant)
}

fn witness_search(number: Int, discriminant: Int) -> WitnessSearch {
  WitnessSearch(
    number,
    discriminant,
    witness(1, { 1 - discriminant } / 4, number),
  )
}
