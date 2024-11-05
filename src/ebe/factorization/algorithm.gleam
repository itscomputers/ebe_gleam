//// Factorization algorithm module
////    - uses various algorithms to search for a non-trivial divisor of a number

import gleam/list
import gleam/option.{type Option, None, Some}

import ebe/factorization/algorithm/pollard_rho.{type PollardRho}

pub type Algorithm {
  PollardRhoAlgorithm(number: Int, algo: PollardRho)
}

/// Divisor-finding algorithm
pub fn divisor(number: Int) -> Option(Int) {
  number |> algorithms |> divisor_loop
}

fn divisor_loop(algorithms: List(Algorithm)) -> Option(Int) {
  case algorithms {
    [] -> None
    _ -> {
      case algorithms |> non_trivial_divisor {
        None -> algorithms |> list.map(step) |> prune |> divisor_loop
        Some(divisor) -> Some(divisor)
      }
    }
  }
}

fn algorithms(number: Int) -> List(Algorithm) {
  [2, 3, 4, 6, 7, 8, 9]
  |> list.map(fn(seed) {
    PollardRhoAlgorithm(
      number,
      pollard_rho.new(number, seed, fn(x) { x * x + 1 }),
    )
  })
}

fn get_divisor(algorithm: Algorithm) -> Int {
  case algorithm {
    PollardRhoAlgorithm(_, pr) -> pr |> pollard_rho.divisor
  }
}

fn step(algorithm: Algorithm) -> Algorithm {
  case algorithm {
    PollardRhoAlgorithm(number, pr) ->
      PollardRhoAlgorithm(number, pr |> pollard_rho.step)
  }
}

fn prune(algorithms: List(Algorithm)) -> List(Algorithm) {
  algorithms
  |> list.filter(fn(algorithm) { get_divisor(algorithm) != algorithm.number })
}

fn non_trivial_divisor(algorithms: List(Algorithm)) -> Option(Int) {
  algorithms
  |> list.find(fn(a) { a |> get_divisor |> is_non_trivial(a.number) })
  |> option.from_result
  |> option.map(get_divisor)
}

fn is_non_trivial(divisor: Int, number: Int) -> Bool {
  1 < divisor && divisor < number
}
