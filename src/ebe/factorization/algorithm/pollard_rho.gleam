//// Pollard-rho divisor-finding algorithm

import ebe/integer

pub opaque type State {
  State(
    number: Int,
    divisor: Int,
    value_i: Int,
    value_2i: Int,
    function: fn(Int) -> Int,
  )
}

pub fn new(number: Int, seed: Int, function: fn(Int) -> Int) -> State {
  State(number: number, divisor: 1, value_i: 1, value_2i: 1, function: function)
  |> set_initial_values(seed)
  |> update_divisor
}

pub fn step(state: State) -> State {
  case state.divisor > 1 {
    True -> state
    False -> state |> update_values |> update_divisor
  }
}

pub fn number(state: State) -> Int {
  state.number
}

pub fn divisor(state: State) -> Int {
  state.divisor
}

fn set_initial_values(state: State, seed: Int) -> State {
  State(
    ..state,
    value_i: seed |> next_value(state),
    value_2i: seed
      |> next_value(state)
      |> next_value(state),
  )
}

fn update_values(state: State) -> State {
  State(
    ..state,
    value_i: state.value_i |> next_value(state),
    value_2i: state.value_2i |> next_value(state) |> next_value(state),
  )
}

fn update_divisor(state: State) -> State {
  State(
    ..state,
    divisor: state.number |> integer.gcd(state.value_2i - state.value_i),
  )
}

fn next_value(value: Int, state: State) -> Int {
  value
  |> integer.mod(state.number)
  |> state.function
  |> integer.mod(state.number)
}
