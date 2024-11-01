//// Miller-Rabin algorithm
////    - determines the primality of a number according to witnesses
////    - assumes that the number is > 2
////    - if number < max_cutoff, then a predetermined set of witnesses
////      can determine its primality in a deterministic way
////    - a random witness will incorrectly observe a number as probably
////      prime with probability at less than 1 / 4
////    - a list of random witnesses will incorrectly observe a number as
////      probably prime with probability less than (1 / 4) ^ witness_count

import gleam/int
import gleam/list
import gleam/set.{type Set}

import ebe/integer
import ebe/primality/observation.{
  type Observation, Composite, ProbablePrime, Undetermined,
}

/// Upper limit for deterministic observation by predetermined witnesses
const max_cutoff = 341_550_071_728_321

/// Witness for observed primality
pub type Witness {
  Witness(value: Int)
}

/// Whether to use the determinstic observations
pub fn use_deterministic(number: Int) -> Bool {
  number < max_cutoff
}

/// Observe deterministic primality of number using specific witnesses
pub fn observe_deterministic(number: Int) -> Observation {
  number
  |> observe(by: deterministic_witnesses(number))
  |> observation.concretize
}

/// Observe probabilistic primality of number using random witnesses
pub fn observe_random(number: Int, count witness_count: Int) -> Observation {
  number |> observe(by: random_witnesses(number, witness_count))
}

/// Combined observation by a list of witnesses
pub fn observe(number: Int, by witnesses: List(Witness)) -> Observation {
  Undetermined |> observe_loop(number, witnesses)
}

/// Combined observation - recursive method
fn observe_loop(
  obs: Observation,
  number: Int,
  witnesses: List(Witness),
) -> Observation {
  case obs |> observation.concrete, witnesses {
    True, _ -> obs
    False, [] -> obs
    False, [witness, ..rest] ->
      obs
      |> observation.combine(number |> observation(by: witness))
      |> observe_loop(number, rest)
  }
}

/// Observation by a witness
pub fn observation(number: Int, by witness: Witness) -> Observation {
  let #(exp, rest) = integer.p_adic_unsafe(number - 1, 2)
  let check = integer.exp_mod_unsafe(witness.value, by: rest, mod: number)
  case
    check
    |> prime_observation(when: 1)
    |> observation.combine(check |> prime_observation(when: number - 1))
  {
    Undetermined -> observation_loop(number, check, witness, remaining: exp)
    observation -> observation
  }
}

/// Observation - recursive function
fn observation_loop(
  number: Int,
  check: Int,
  witness: Witness,
  remaining remaining: Int,
) -> Observation {
  let check = integer.exp_mod_unsafe(check, by: 2, mod: number)
  case check, remaining {
    _, 0 -> Composite
    1, _ -> Composite
    _, _ ->
      case check |> prime_observation(when: number - 1) {
        Undetermined -> observation_loop(number, check, witness, remaining - 1)
        observation -> observation
      }
  }
}

/// Prime observation for a checked value against an expected value
fn prime_observation(check: Int, when expected: Int) -> Observation {
  case check == expected {
    True -> ProbablePrime
    False -> Undetermined
  }
}

/// List of deterministic witnesses
fn deterministic_witnesses(number: Int) -> List(Witness) {
  [
    #(1, 2),
    #(2047, 3),
    #(1_373_653, 5),
    #(25_326_001, 7),
    #(3_215_031_751, 11),
    #(2_152_302_898_747, 13),
    #(3_474_749_660_383, 17),
  ]
  |> list.take_while(fn(tuple) { number >= tuple.0 })
  |> list.map(fn(tuple) { Witness(tuple.1) })
}

/// List of size count of random probabilistic witnesses
fn random_witnesses(number: Int, count: Int) -> List(Witness) {
  random_set(lower: 2, upper: number - 1, count: count)
  |> set.to_list
  |> list.map(fn(value) { Witness(value) })
}

/// Set of count random elements between lower and upper inclusive
fn random_set(lower lower: Int, upper upper: Int, count count: Int) -> Set(Int) {
  case upper - lower <= count + 1 {
    True -> list.range(lower, upper) |> set.from_list
    False -> random_set_loop(set.new(), lower, upper, count)
  }
}

/// Random set - recursive function
fn random_set_loop(
  curr_set: Set(Int),
  lower: Int,
  upper: Int,
  count: Int,
) -> Set(Int) {
  case { curr_set |> set.size } == count {
    True -> curr_set
    _ ->
      curr_set
      |> set.insert(lower + int.random(upper - lower))
      |> random_set_loop(lower, upper, count)
  }
}
