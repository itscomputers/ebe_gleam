//// Williams p+1 algorithm

import ebe/integer
import ebe/sequence/lucas.{type LucasSequence}

pub opaque type State {
  State(number: Int, divisor: Int, seq: LucasSequence, index: Int)
}

pub fn new(number: Int, seed: Int) -> State {
  State(
    number: number,
    divisor: 1,
    seq: lucas.new_mod_unsafe(seed, 1, number) |> lucas.next,
    index: 2,
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
    seq: lucas.new_mod_unsafe(state |> get_v, 1, state.number)
      |> lucas.advance(by: state.index),
    index: state.index + 1,
  )
}

fn update_divisor(state: State) -> State {
  State(..state, divisor: state.number |> integer.gcd(get_v(state) - 2))
}

fn get_v(state: State) -> Int {
  lucas.value(state.seq).v
}
