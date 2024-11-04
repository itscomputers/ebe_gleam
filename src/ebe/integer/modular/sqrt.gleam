//// Modular square roots
////    - calculated relative to a prime modulus
////    - if prime is odd, requires jacobi symbol == 1

import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result

import ebe/integer
import ebe/integer/modular
import ebe/primality

/// Record to store modular square roots
pub type SquareRoot {
  SquareRoot(root: Int, other_root: Int, prime: Int)
}

/// Record used internally in Tonell-Shanks algorithm
type TonelliShanksParams {
  TonelliShanksParams(m: Int, c: Int, t: Int, r: Int)
}

/// Square root of number modulo prime
///   - return Error if jacobi symbol != 1
pub fn sqrt(prime: Int, number: Int) -> Result(SquareRoot, Nil) {
  case prime {
    2 -> build_square_root(number |> integer.mod(prime), prime) |> Ok
    _ ->
      prime
      |> check_jacobi_symbol(number)
      |> check_primality(prime)
      |> result.try(fn(_) {
        case prime |> integer.mod(4) {
          1 -> prime |> tonelli_shanks(number) |> Ok
          _ -> prime |> trivial_sqrt(number) |> Ok
        }
      })
  }
}

/// Square roots of number for a prime == 3 mod(4), using trivial identity
fn trivial_sqrt(prime: Int, number: Int) -> SquareRoot {
  number
  |> modular.exp_unsafe({ prime + 1 } / 4, prime)
  |> build_square_root(prime)
}

/// Squares roots of number for a prime == 1 mod(4), using Tonelli-Shanks 
fn tonelli_shanks(prime: Int, number: Int) -> SquareRoot {
  tonelli_shanks_loop(prime, number, tonelli_shanks_params(prime, number))
}

/// Tonelli-Shanks - recusive
fn tonelli_shanks_loop(
  prime: Int,
  number: Int,
  params: TonelliShanksParams,
) -> SquareRoot {
  case params.t {
    0 | 1 -> params.r |> build_square_root(prime)
    _ -> {
      let index = tonelli_shanks_index(params.t, 0, prime)
      let b =
        params.c
        |> modular.exp_unsafe(
          2
            |> modular.exp_unsafe(params.m - index - 1, prime),
          prime,
        )
      let b2 = b |> modular.exp_unsafe(2, prime)
      tonelli_shanks_loop(
        prime,
        number,
        TonelliShanksParams(
          index,
          b2,
          modular.multiply_unsafe(params.t, b2, prime),
          modular.multiply_unsafe(params.r, b, prime),
        ),
      )
    }
  }
}

/// Construct Tonelli-Shanks parameters
fn tonelli_shanks_params(prime: Int, number: Int) -> TonelliShanksParams {
  let #(m, q) = integer.p_adic_unsafe(prime - 1, 2)
  let z = non_residue(prime, 1)
  let c = z |> modular.exp_unsafe(q, prime)
  let t = number |> modular.exp_unsafe(q, prime)
  let r = number |> modular.exp_unsafe({ q + 1 } / 2, prime)
  TonelliShanksParams(m, c, t, r)
}

/// Index-function used in internals of Tonell-Shanks
fn tonelli_shanks_index(value: Int, index: Int, prime: Int) {
  case value {
    1 -> index
    _ ->
      tonelli_shanks_index(
        value |> modular.exp_unsafe(2, prime),
        index + 1,
        prime,
      )
  }
}

/// Square roots of -1 for a prime == 1 mod(4), using Wilson's theorem
/// This is slower than calling sqrt(prime, -1)
pub fn wilson(prime: Int) -> Result(SquareRoot, Nil) {
  case prime |> integer.mod(by: 4) {
    1 ->
      case prime |> primality.is_prime {
        True -> wilson_unsafe(prime) |> Ok
        False -> Nil |> Error
      }
    _ -> Nil |> Error
  }
}

/// Unsafe Wilson algorithm
fn wilson_unsafe(prime: Int) -> SquareRoot {
  case prime {
    2 -> SquareRoot(1, 1, prime)
    _ ->
      list.range(2, { prime - 1 } / 2)
      |> list.fold(from: 1, with: fn(acc, val) {
        modular.multiply_unsafe(acc, val, prime)
      })
      |> build_square_root(prime)
  }
}

/// Square roots of -1 for a prime == 1 mod(4), using Legendre's method
pub fn legendre(prime: Int) -> Result(SquareRoot, Nil) {
  case prime |> integer.mod(by: 4) {
    1 ->
      case prime |> primality.is_prime {
        True -> legendre_loop(2, prime) |> Ok
        False -> Nil |> Error
      }
    _ -> Nil |> Error
  }
}

/// Unsafe Legendre algorithm - recursive
fn legendre_loop(value: Int, prime: Int) -> SquareRoot {
  case value |> modular.jacobi_symbol_unsafe(prime) {
    -1 ->
      value
      |> modular.exp_unsafe({ prime - 1 } / 4, prime)
      |> build_square_root(prime)
    _ -> legendre_loop(value + 1, prime)
  }
}

/// Construct square root record
fn build_square_root(value: Int, prime: Int) -> SquareRoot {
  case value |> int.compare(prime - value) {
    Eq -> SquareRoot(value, value, prime)
    Gt -> SquareRoot(prime - value, value, prime)
    Lt -> SquareRoot(value, prime - value, prime)
  }
}

/// Find a non-residue modulo a prime
fn non_residue(prime: Int, z: Int) -> Int {
  case z == prime || modular.jacobi_symbol_unsafe(z, prime) == -1 {
    True -> z
    False -> non_residue(prime, z + 1)
  }
}

/// Ensure jacobi symbol == 1
fn check_jacobi_symbol(prime: Int, number: Int) -> Result(Bool, Nil) {
  case number |> modular.jacobi_symbol_unsafe(prime) {
    1 -> True |> Ok
    _ -> Nil |> Error
  }
}

/// Ensure prime is a prime number
fn check_primality(res: Result(Bool, Nil), prime: Int) -> Result(Bool, Nil) {
  res
  |> result.try(fn(_) {
    case prime |> primality.is_prime {
      True -> True |> Ok
      False -> Nil |> Error
    }
  })
}
