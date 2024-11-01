//// Lucas primality test

import gleam/list

import ebe/integer
import ebe/primality/observation.{
  type Observation, Composite, DivisorFound, Indeterminate, ProbablePrime,
  StrongProbablePrime, Undetermined,
}
import ebe/sequence/lucas.{type LucasSequence}

pub type Witness {
  Witness(value: LucasSequence, strong: Bool)
}

/// Lucas strong probable prime observation
/// Assumes number > 2 and number odd
pub fn observation(number: Int, by witness: Witness) -> Observation {
  case number |> first_observation(witness.value) {
    Undetermined -> {
      let jacobi =
        witness.value
        |> lucas.discriminant
        |> integer.jacobi_symbol_unsafe(number)
      let delta = number - jacobi
      let #(upper, index) = integer.p_adic_unsafe(delta, 2)
      let witness =
        Witness(..witness, value: witness.value |> lucas.advance(by: index))
        |> observation_loop(remaining: upper - 1)
      let q = { witness.value |> lucas.value }.q
      case
        prime_condition(witness |> double, number, delta, q),
        witness.strong
      {
        False, _ -> Composite
        True, True -> StrongProbablePrime
        True, False -> ProbablePrime
      }
    }
    observation -> observation
  }
}

fn observation_loop(witness: Witness, remaining remaining: Int) -> Witness {
  case remaining {
    0 -> witness
    _ ->
      witness
      |> double
      |> set_strong
      |> observation_loop(remaining: remaining - 1)
  }
}

fn prime_condition(witness: Witness, number: Int, delta: Int, q: Int) -> Bool {
  let seq = witness.value
  let value = seq |> lucas.value
  let jacobi = integer.jacobi_symbol_unsafe(seq |> lucas.q, number)
  value.u == 0
  && {
    delta == number + 1
    && {
      value.v == { seq |> lucas.p } % number
      && q == { seq |> lucas.q } * jacobi % number
    }
    || { q == jacobi % number }
  }
}

fn first_observation(number: Int, seq: LucasSequence) -> Observation {
  let divisors =
    [seq |> lucas.p, seq |> lucas.q, seq |> lucas.discriminant]
    |> list.map(fn(value) { integer.gcd(number, value) })

  case divisors |> list.any(fn(value) { value == number }) {
    True -> Indeterminate
    False ->
      case divisors |> list.find(fn(divisor) { divisor > 1 }) {
        Ok(divisor) -> DivisorFound(divisor)
        Error(Nil) -> Undetermined
      }
  }
}

fn double(witness: Witness) -> Witness {
  Witness(..witness, value: witness.value |> lucas.double)
}

fn set_strong(witness: Witness) -> Witness {
  case witness.value |> lucas.value |> fn(value) { value.v == 0 } {
    True -> Witness(..witness, strong: True)
    False -> witness
  }
}
