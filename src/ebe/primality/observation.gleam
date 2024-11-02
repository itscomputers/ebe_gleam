import gleam/list

/// Observation for a probabilistic primality test
///   - Indeterminate is for integers < 2
///   - Undetermined is when a determination has yet to be made
///   - Indeterminate, Composite, DivisorFound, and Prime are final
pub type Observation {
  Composite
  DivisorFound(divisor: Int)
  Indeterminate
  Prime
  ProbablePrime
  StrongProbablePrime
  Undetermined
}

/// Reduce a list of observations into a single observation
pub fn reduce(observations: List(Observation)) -> Observation {
  observations |> list.fold(from: Undetermined, with: combine)
}

/// Reduce a list of observations into a single observation
pub fn reduce_lazy(observations: List(fn() -> Observation)) -> Observation {
  observations |> list.fold(from: Undetermined, with: combine_lazy)
}

/// Combine two observations into a single observation
pub fn combine(observation: Observation, other: Observation) -> Observation {
  observation |> combine_lazy(fn() { other })
}

/// Lazily combine two observations into a single observation
///   - does not execute other observation if first is concrete
pub fn combine_lazy(
  observation: Observation,
  other: fn() -> Observation,
) -> Observation {
  case observation |> concrete {
    True -> observation
    False ->
      case observation, other() {
        Undetermined, observation -> observation
        _, Indeterminate -> Indeterminate
        _, Prime -> Prime
        _, Composite -> Composite
        StrongProbablePrime, _ -> StrongProbablePrime
        _, StrongProbablePrime -> StrongProbablePrime
        _, _ -> ProbablePrime
      }
  }
}

/// Whether an observation is final or partial
pub fn concrete(observation: Observation) -> Bool {
  case observation {
    Indeterminate | Composite | Prime | DivisorFound(_) -> True
    _ -> False
  }
}

/// Convert partial observation to concrete observation
pub fn concretize(observation: Observation) -> Observation {
  case observation {
    ProbablePrime | StrongProbablePrime -> Prime
    DivisorFound(_) -> Composite
    _ -> observation
  }
}
