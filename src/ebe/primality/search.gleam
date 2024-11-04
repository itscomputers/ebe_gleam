//// Prime searching module

import gleam/iterator.{type Iterator, Done, Next}
import gleam/list

import ebe/integer
import ebe/primality/algorithm

pub opaque type PrimeSearch {
  PrimeSearch(next: Int, iter: Iterator(Int), sieve: List(Int))
}

pub fn new() -> PrimeSearch {
  from_sieve([2, 3, 5])
}

pub fn from_sieve(sieve sieve: List(Int)) -> PrimeSearch {
  case sieve {
    [] -> from_sieve([2, 3, 5])
    [2, ..rest] ->
      PrimeSearch(next: 2, iter: rest |> iterator.from_list, sieve: sieve)
    _ -> from_sieve([2, ..sieve])
  }
}

pub fn step(search: PrimeSearch) -> PrimeSearch {
  case search.iter |> iterator.step {
    Next(prime, iter) -> PrimeSearch(..search, next: prime, iter: iter)
    Done -> search |> advance(to: search.next + 1)
  }
}

pub fn next(search: PrimeSearch) -> Int {
  search.next
}

pub fn advance(search: PrimeSearch, to lower: Int) -> PrimeSearch {
  case prime_iter(lower, search.sieve) |> iterator.step {
    Next(prime, iter) -> PrimeSearch(..search, next: prime, iter: iter)
    Done -> panic
  }
}

pub fn take_until(search: PrimeSearch, bound value: Int) -> List(Int) {
  case search.next <= search |> max_sieve_prime {
    True ->
      list.concat([
        search.sieve |> list.drop_while(fn(p) { p < search.next }),
        search |> advance(max_sieve_prime(search) + 1) |> take_until(value),
      ])
    False -> [
      search.next,
      ..search.iter
      |> iterator.take_while(fn(p) { p < value })
      |> iterator.to_list
    ]
  }
}

fn prime_iter(lower: Int, sieve: List(Int)) -> Iterator(Int) {
  { lower + 1 - integer.mod(lower, 2) }
  |> iterator.iterate(fn(number) { number + 2 })
  |> iterator.filter(sieve_filter(sieve))
  |> iterator.filter(algorithm.is_prime)
}

fn sieve_filter(sieve: List(Int)) -> fn(Int) -> Bool {
  fn(number) {
    sieve |> list.all(fn(prime) { number |> integer.mod(prime) != 0 })
  }
}

fn max_sieve_prime(search: PrimeSearch) -> Int {
  let assert Ok(last) = search.sieve |> list.last
  last
}
