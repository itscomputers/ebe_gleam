import ebe/integer
import ebe/primality
import ebe/primality/algorithm/lucas_strong_probable_prime as lucas_primality
import ebe/primality/algorithm/miller_rabin
import ebe/primality/iterator.{type Primes} as iter
import ebe/primality/observation.{
  type Observation, Composite, DivisorFound, Indeterminate, Prime, ProbablePrime,
  StrongProbablePrime, Undetermined,
}

import gleam/bool
import gleam/int
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn next_prime_test() {
  let assert_next_prime = fn(primes: Primes, expected: Int) -> Primes {
    primes |> iter.next |> should.equal(expected)
    primes |> iter.advance
  }

  iter.new()
  |> assert_next_prime(2)
  |> assert_next_prime(3)
  |> assert_next_prime(5)
  |> assert_next_prime(7)
  |> assert_next_prime(11)
  |> assert_next_prime(13)
  |> assert_next_prime(17)
  |> assert_next_prime(19)
  |> assert_next_prime(23)
}

pub fn primes_before_test() {
  primality.primes_before(29)
  |> should.equal(
    primes_up_to_100()
    |> list.take_while(fn(p) { p < 29 }),
  )
  primality.primes_before(101)
  |> should.equal(primes_up_to_100())
}

pub fn is_prime_naive_test() {
  primes_up_to_100()
  |> list.map(primality.is_prime_naive)
  |> list.all(fn(b) { b })
  |> should.be_true

  non_primes_up_to_100()
  |> list.map(primality.is_prime_naive)
  |> list.any(fn(b) { b })
  |> should.be_false
}

pub fn is_prime_test() {
  list.range(-100, 500)
  |> list.each(fn(number) {
    number
    |> primality.is_prime
    |> should.equal(number |> primality.is_prime_naive)
  })

  let primes = large_primes()
  let assert Ok(lower) = primes |> list.first
  let assert Ok(upper) = primes |> list.last

  list.range(lower, upper)
  |> list.partition(fn(number) { primes |> list.contains(number) })
  |> fn(tuple) {
    tuple.0
    |> list.each(fn(number) { number |> primality.is_prime |> should.be_true })
    tuple.1
    |> list.each(fn(number) { number |> primality.is_prime |> should.be_false })
  }
}

pub fn large_primes_miller_rabin_test() {
  large_primes_test(fn(number) {
    number |> miller_rabin.observe_random(count: 10)
  })
}

pub fn large_primes_lucas_strong_probable_prime_test() {
  large_primes_test(fn(number) {
    number |> lucas_primality.observe_random(count: 10)
  })
}

fn large_primes_test(observation_func: fn(Int) -> Observation) {
  let primes = large_primes()
  let assert Ok(lower) = primes |> list.first
  let assert Ok(upper) = primes |> list.last

  list.range(lower, upper)
  |> list.filter(fn(number) { number % 2 == 1 && !integer.is_square(number) })
  |> list.partition(fn(number) { primes |> list.contains(number) })
  |> fn(tuple) {
    tuple.0
    |> list.each(fn(number) {
      number
      |> observation_func
      |> observation.concretize
      |> should.equal(Prime)
    })
    tuple.1
    |> list.each(fn(number) {
      number
      |> observation_func
      |> observation.concretize
      |> should.equal(Composite)
    })
  }
}

pub fn reduce_observations_test() {
  let observations = [
    #([Composite, Prime, StrongProbablePrime, ProbablePrime], Composite),
    #([Prime, Composite, StrongProbablePrime, ProbablePrime], Prime),
    #([Prime, StrongProbablePrime, Composite, ProbablePrime], Prime),
    #([Prime, StrongProbablePrime, ProbablePrime, Composite], Prime),
    #([Prime, StrongProbablePrime, ProbablePrime], Prime),
    #([StrongProbablePrime, Prime, ProbablePrime], Prime),
    #([StrongProbablePrime, ProbablePrime, Prime], Prime),
    #([StrongProbablePrime, ProbablePrime], StrongProbablePrime),
    #([ProbablePrime, StrongProbablePrime], StrongProbablePrime),
    #([ProbablePrime, ProbablePrime], ProbablePrime),
  ]

  observations
  |> list.each(fn(tuple) {
    tuple.0 |> observation.reduce |> should.equal(tuple.1)
    [Undetermined, ..tuple.0] |> observation.reduce |> should.equal(tuple.1)
  })

  observations
  |> list.map(fn(tuple) {
    #(tuple.0 |> list.map(fn(obs) { fn() { obs } }), tuple.1)
  })
  |> list.each(fn(tuple) {
    tuple.0 |> observation.reduce_lazy |> should.equal(tuple.1)
    [fn() { Undetermined }, ..tuple.0]
    |> observation.reduce_lazy
    |> should.equal(tuple.1)
  })
}

pub fn reduce_observations_lazy_test() {
  [Composite, Prime, StrongProbablePrime, ProbablePrime]
  |> list.map(fn(obs) { fn() { obs } })
  |> list.fold(from: Undetermined, with: fn(acc, obs) {
    acc |> observation.combine_lazy(obs)
  })
  |> should.equal(Composite)
}

pub fn miller_rabin_test() {
  primes_up_to_100()
  |> list.drop(1)
  |> list.each(fn(number) {
    number
    |> miller_rabin.observe_deterministic
    |> should.equal(Prime)
  })

  non_primes_up_to_100()
  |> list.filter(fn(number) { number > 2 })
  |> list.each(fn(number) {
    number
    |> miller_rabin.observe_deterministic
    |> should.equal(case number < 2 {
      True -> Indeterminate
      False -> Composite
    })
  })
}

pub fn miller_rabin_observation_test() {
  list.range(3, 2046)
  |> list.each(fn(number) {
    case
      number
      |> miller_rabin.observation(by: miller_rabin.Witness(2))
    {
      ProbablePrime -> number |> primality.is_prime_naive |> should.be_true
      _ -> number |> primality.is_prime_naive |> should.be_false
    }
  })
  miller_rabin.observation(2047, by: miller_rabin.Witness(2))
  |> should.equal(ProbablePrime)
  miller_rabin.observation(2047, by: miller_rabin.Witness(3))
  |> should.equal(Composite)
}

pub fn miller_rabin_randomized_test() {
  list.range(1, 20)
  |> list.each(fn(_) {
    let number = 1000 + int.random(10_000)
    case number |> miller_rabin.observe_deterministic {
      Prime -> number |> primality.is_prime_naive |> should.be_true
      _ -> number |> primality.is_prime_naive |> should.be_false
    }
  })
}

pub fn lucas_observation_test() {
  list.range(3, 100)
  |> list.filter(fn(number) {
    { number % 2 == 1 && number != 5 } || number % 10 == 0
  })
  |> list.each(fn(number) {
    case
      number
      |> lucas_primality.observation(by: lucas_primality.witness(1, -1, number))
    {
      Composite | DivisorFound(_) ->
        number |> primality.is_prime_naive |> should.be_false
      _ -> number |> primality.is_prime_naive |> should.be_true
    }
  })
}

fn primes_up_to_100() {
  [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
    73, 79, 83, 89, 97,
  ]
}

fn non_primes_up_to_100() {
  list.range(-5, 100)
  |> list.filter(fn(a) { primes_up_to_100() |> list.contains(a) |> bool.negate })
}

fn large_primes() {
  [
    341_550_071_728_361, 341_550_071_728_373, 341_550_071_728_387,
    341_550_071_728_417, 341_550_071_728_471, 341_550_071_728_501,
    341_550_071_728_519, 341_550_071_728_531, 341_550_071_728_549,
    341_550_071_728_573,
  ]
}
