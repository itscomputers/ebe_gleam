//// Fermat's algorithm

import gleam/option.{type Option, None, Some}

import ebe/integer

pub opaque type State {
  State(number: Int, divisor: Int, value: Int)
}

pub fn new(number: Int) -> State {
  State(number: number, divisor: 1, value: integer.sqrt_unsafe(number))
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
  State(..state, value: state.value + 1)
}

fn update_divisor(state: State) -> State {
  case state |> square {
    Some(b) -> State(..state, divisor: state.value + integer.sqrt_unsafe(b))
    None -> state
  }
}

fn square(state: State) -> Option(Int) {
  state.value * state.value - state.number
  |> fn(b) {
    case b |> integer.is_square {
      True -> Some(b)
      False -> None
    }
  }
}
