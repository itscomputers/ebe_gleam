/// Primality observation algorithms
/// Observation for primality
import ebe/integer
import ebe/primality/algorithm/lucas_strong_probable_prime as lucas
import ebe/primality/algorithm/miller_rabin
import ebe/primality/observation.{
  type Observation, Composite, Indeterminate, Prime, Undetermined,
}

/// Primality determination
///   - deterministic result if number < 341_550_071_728_321 
///   - probabilistic result otherwise
///       - probability of incorrect classification < 4^(-10) for Miller-Rabin test
pub fn is_prime(number: Int) {
  case number |> primality_observation |> observation.concretize {
    Prime -> True
    _ -> False
  }
}

/// Final primality observation from chain of observations
///   - stops early once a concrete observation is found
pub fn primality_observation(number: Int) -> Observation {
  Undetermined
  |> apply(number, when: less_than_two, do: is(Indeterminate))
  |> apply(number, when: equals_two, do: is(Prime))
  |> apply(number, when: is_even, do: is(Composite))
  |> apply(number, when: integer.is_square, do: is(Composite))
  |> apply_deterministic_miller_rabin(number)
  |> apply_random_miller_rabin(number)
  |> apply_random_lucas(number)
}

/// Conditionally apply a new observation
fn apply(
  obs: Observation,
  number: Int,
  when condition: fn(Int) -> Bool,
  do get_observation: fn(Int) -> Observation,
) -> Observation {
  case condition(number) {
    True -> obs |> observation.combine_lazy(fn() { number |> get_observation })
    False -> obs
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
  obs
  |> observation.combine_lazy(fn() { number |> miller_rabin.observe_random(10) })
}

/// Use the probabilistic Lucas strong probable prime test with 5 random witnesses
///   - incorrect with probability less than (4 / 15) ^ 5
fn apply_random_lucas(obs: Observation, number: Int) -> Observation {
  obs |> observation.combine_lazy(fn() { number |> lucas.observe_random(10) })
}
