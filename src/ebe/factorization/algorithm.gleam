//// Factorization algorithm module
////    - uses various algorithms to search for a non-trivial divisor of a number

import gleam/list
import gleam/option.{type Option, None, Some}

import ebe/factorization/algorithm/fermat
import ebe/factorization/algorithm/pollard_minus_one
import ebe/factorization/algorithm/pollard_rho
import ebe/factorization/algorithm/trial_division
import ebe/factorization/algorithm/williams_plus_one

pub opaque type Algorithm {
  Algorithm(state: State, status: Status)
}

type Status {
  NonTrivialDivisor
  TrivialDivisor
  Incomplete
}

type State {
  FermatState(inner: fermat.State)
  MinusOneState(inner: pollard_minus_one.State)
  PlusOneState(inner: williams_plus_one.State)
  RhoState(inner: pollard_rho.State)
  TrialDivisionState(inner: trial_division.State)
}

pub fn find_divisor(number: Int) -> Option(Int) {
  number |> default_algorithms |> concurrent
}

pub fn fermat(number: Int) -> Algorithm {
  FermatState(fermat.new(number)) |> build
}

pub fn minus_one(number: Int, seed seed: Int) -> Algorithm {
  MinusOneState(pollard_minus_one.new(number, seed)) |> build
}

pub fn plus_one(number: Int, seed seed: Int) -> Algorithm {
  PlusOneState(williams_plus_one.new(number, seed)) |> build
}

pub fn rho(
  number: Int,
  seed seed: Int,
  func function: fn(Int) -> Int,
) -> Algorithm {
  RhoState(pollard_rho.new(number, seed, function)) |> build
}

pub fn trial_division(number: Int) -> Algorithm {
  TrialDivisionState(trial_division.new(number)) |> build
}

pub fn run(algorithm: Algorithm) -> Option(Int) {
  case algorithm.status {
    NonTrivialDivisor -> algorithm |> divisor |> Some
    TrivialDivisor -> None
    Incomplete -> algorithm |> step |> run
  }
}

pub fn step(algorithm: Algorithm) -> Algorithm {
  case algorithm.status {
    Incomplete -> algorithm |> update_state |> update_status
    _ -> algorithm
  }
}

pub fn concurrent(algorithms: List(Algorithm)) -> Option(Int) {
  case algorithms {
    [] -> None
    _ ->
      case algorithms |> list.find(fn(a) { a.status == NonTrivialDivisor }) {
        Ok(algorithm) -> algorithm |> divisor |> Some
        Error(Nil) -> algorithms |> list.map(step) |> prune |> concurrent
      }
  }
}

fn build(state: State) -> Algorithm {
  Algorithm(state: state, status: Incomplete)
}

fn update_state(algorithm: Algorithm) -> Algorithm {
  Algorithm(..algorithm, state: algorithm |> next_state)
}

fn update_status(algorithm: Algorithm) -> Algorithm {
  Algorithm(..algorithm, status: algorithm |> next_status)
}

fn divisor(algorithm: Algorithm) -> Int {
  case algorithm.state {
    FermatState(inner) -> inner |> fermat.divisor
    MinusOneState(inner) -> inner |> pollard_minus_one.divisor
    PlusOneState(inner) -> inner |> williams_plus_one.divisor
    RhoState(inner) -> inner |> pollard_rho.divisor
    TrialDivisionState(inner) -> inner |> trial_division.divisor
  }
}

fn number(algorithm: Algorithm) -> Int {
  case algorithm.state {
    FermatState(inner) -> inner |> fermat.number
    MinusOneState(inner) -> inner |> pollard_minus_one.number
    PlusOneState(inner) -> inner |> williams_plus_one.number
    RhoState(inner) -> inner |> pollard_rho.number
    TrialDivisionState(inner) -> inner |> trial_division.number
  }
}

fn next_state(algorithm: Algorithm) -> State {
  case algorithm.state {
    FermatState(inner) -> FermatState(inner |> fermat.step)
    MinusOneState(inner) -> MinusOneState(inner |> pollard_minus_one.step)
    PlusOneState(inner) -> PlusOneState(inner |> williams_plus_one.step)
    RhoState(inner) -> RhoState(inner |> pollard_rho.step)
    TrialDivisionState(inner) ->
      TrialDivisionState(inner |> trial_division.step)
  }
}

fn next_status(algorithm: Algorithm) -> Status {
  case algorithm |> has_divisor {
    True ->
      case algorithm |> has_trivial_divisor {
        True -> TrivialDivisor
        False -> NonTrivialDivisor
      }
    False -> algorithm.status
  }
}

fn has_divisor(algorithm: Algorithm) -> Bool {
  algorithm |> divisor > 1
}

fn has_trivial_divisor(algorithm: Algorithm) -> Bool {
  algorithm |> divisor == algorithm |> number
}

fn prune(algorithms: List(Algorithm)) -> List(Algorithm) {
  algorithms |> list.filter(fn(a) { a.status != TrivialDivisor })
}

fn default_algorithms(number: Int) -> List(Algorithm) {
  [default_rho, default_minus, default_plus, default_trivial]
  |> list.map(fn(default) { default(number) })
  |> list.flatten
}

fn default_rho(number: Int) -> List(Algorithm) {
  [2, 3, 4, 6, 7, 8, 9]
  |> list.map(fn(seed) { rho(number, seed, fn(n) { n * n + 1 }) })
}

fn default_minus(number: Int) -> List(Algorithm) {
  [2]
  |> list.map(fn(seed) { minus_one(number, seed) })
}

fn default_plus(number: Int) -> List(Algorithm) {
  [5, -7]
  |> list.map(fn(seed) { plus_one(number, seed) })
}

fn default_trivial(number: Int) -> List(Algorithm) {
  [trial_division(number), fermat(number)]
}
