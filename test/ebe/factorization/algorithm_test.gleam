import gleam/list
import gleeunit
import gleeunit/should

import ebe/factorization/algorithm
import ebe/integer
import ebe/primality

pub fn main() {
  gleeunit.main()
}

pub fn divisors_test() {
  list.range(2, 1000)
  |> list.filter(fn(n) { !primality.is_prime(n) })
  |> list.each(fn(number) {
    case number {
      4 | 8 | 25 -> {
        number |> algorithm.divisor |> should.be_none
      }
      _ -> {
        let divisor = number |> algorithm.divisor |> should.be_some
        { 1 < divisor } |> should.be_true
        { divisor < number } |> should.be_true
        number |> integer.mod(divisor) |> should.equal(0)
      }
    }
  })

  primality.primes_before(1000)
  |> list.each(fn(prime) { prime |> algorithm.divisor |> should.be_none })
}
