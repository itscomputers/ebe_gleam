//// Pollard's p-1 factoring algorithm

import ebe/integer
import ebe/integer/modular

pub opaque type State {
  State(number: Int, divisor: Int, value: Int, index: Int)
}

pub fn new(number: Int, seed: Int) -> State {
  State(
    number: number,
    divisor: 1,
    value: seed |> integer.mod(number),
    index: 1,
  )
}

pub fn step(state: State) -> State {
  case state.divisor > 1 {
    True -> state
    False -> state |> update_value |> update_divisor
  }
}

pub fn number(state: State) -> Int {
  state.number
}

pub fn divisor(state: State) -> Int {
  state.divisor
}

fn update_value(state: State) -> State {
  State(
    ..state,
    value: state.value |> modular.exp_unsafe(state.index, state.number),
    index: state.index + 1,
  )
}

fn update_divisor(state: State) -> State {
  State(..state, divisor: state.number |> integer.gcd(state.value - 1))
}
