//// Trial division algorithm

import ebe/primality/eratosthenes.{type Primes}

pub opaque type State {
  State(number: Int, divisor: Int, primes: Primes)
}

pub fn new(number: Int) -> State {
  State(number: number, divisor: 1, primes: eratosthenes.new())
  |> update_divisor
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
  State(..state, primes: state.primes |> eratosthenes.step)
}

fn update_divisor(state: State) -> State {
  case state.number % { state |> prime } {
    0 -> State(..state, divisor: state |> prime)
    _ -> state
  }
}

fn prime(state: State) -> Int {
  state.primes |> eratosthenes.next
}
