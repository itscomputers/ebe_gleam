/// Primality observation algorithms
/// Observation for primality
import ebe/primality/algorithm/miller_rabin
import ebe/primality/observation.{
  type Observation, Composite, Indeterminate, Prime, Undetermined,
}

/// Final primality observation from chain of observations
///   - stops early once a concrete observation is found
pub fn primality_observation(number: Int) -> Observation {
  Undetermined
  |> apply(number, when: less_than_two, do: is(Indeterminate))
  |> apply(number, when: equals_two, do: is(Prime))
  |> apply(number, when: is_even, do: is(Composite))
  |> apply_deterministic_miller_rabin(number)
  |> apply_random_miller_rabin(number)
}

/// Conditionally apply a new observation
fn apply(
  obs: Observation,
  number: Int,
  when condition: fn(Int) -> Bool,
  do get_observation: fn(Int) -> Observation,
) -> Observation {
  case condition(number) {
    True -> obs |> combine_with(number, get_observation)
    False -> obs
  }
}

/// Combine an observation with a new observation
fn combine_with(
  obs: Observation,
  number: Int,
  get_observation: fn(Int) -> Observation,
) -> Observation {
  case obs |> observation.concrete {
    True -> obs
    False -> obs |> observation.combine(number |> get_observation)
  }
}

/// Observation based only on condition
fn is(obs: Observation) -> fn(Int) -> Observation {
  fn(_number) { obs }
}

fn less_than_two(number: Int) -> Bool {
  number < 2
}

fn equals_two(number: Int) -> Bool {
  number == 2
}

fn is_even(number: Int) -> Bool {
  number % 2 == 0
}

/// Use the deterministic Miller-Rabin test if below the max_cutoff
fn apply_deterministic_miller_rabin(
  obs: Observation,
  number: Int,
) -> Observation {
  obs
  |> apply(
    number,
    when: miller_rabin.use_deterministic,
    do: miller_rabin.observe_deterministic,
  )
}

/// Use the probabilistic Miller-Rabin test with 10 random witnesses
///   - incorrect with probability less than (1 / 4) ^ 10
fn apply_random_miller_rabin(obs: Observation, number: Int) -> Observation {
  obs |> combine_with(number, fn(n) { n |> miller_rabin.observe_random(10) })
}
