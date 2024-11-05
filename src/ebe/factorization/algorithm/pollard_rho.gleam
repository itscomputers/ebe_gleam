//// Pollard-rho divisor-finding algorithm

import gleam/iterator.{type Iterator, Done, Next}

import ebe/integer

pub opaque type PollardRho {
  PollardRho(number: Int, divisor: Int, iter: Iterator(State))
}

type State {
  State(value_i: Int, value_2i: Int)
}

pub fn divisor(pr: PollardRho) -> Int {
  pr.divisor
}

pub fn new(number: Int, seed: Int, function: fn(Int) -> Int) -> PollardRho {
  PollardRho(
    number: number,
    divisor: 1,
    iter: iterator.iterate(
      new_state(number, seed, function),
      iter_func(number, function),
    ),
  )
}

pub fn step(pr: PollardRho) -> PollardRho {
  case pr.divisor > 1 {
    True -> PollardRho(..pr, iter: iterator.empty())
    False ->
      case pr.iter |> iterator.step {
        Next(state, iter) ->
          PollardRho(..pr, divisor: state |> get_divisor(pr.number), iter: iter)
        Done -> pr
      }
  }
}

fn iter_func(number: Int, function: fn(Int) -> Int) -> fn(State) -> State {
  fn(state: State) {
    State(
      value_i: state.value_i |> apply(number, function),
      value_2i: state.value_2i
        |> apply(number, function)
        |> apply(number, function),
    )
  }
}

fn new_state(number: Int, seed: Int, function: fn(Int) -> Int) -> State {
  let value_i = seed |> apply(number, function)
  State(value_i: value_i, value_2i: value_i |> apply(number, function))
}

fn apply(value: Int, number: Int, function: fn(Int) -> Int) -> Int {
  value |> integer.mod(number) |> function |> integer.mod(number)
}

fn get_divisor(state: State, number: Int) -> Int {
  integer.gcd(state.value_i - state.value_2i, number)
}
