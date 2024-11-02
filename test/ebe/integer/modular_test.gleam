import ebe/integer
import ebe/integer/modular as m

import gleam/list
import gleam/set
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn add_test() {
  [#(10, 20), #(-10, 20), #(10, -20), #(-10, -20)]
  |> list.each(fn(tuple) {
    list.range(2, 20)
    |> list.each(fn(modulus) {
      m.add(tuple.0, tuple.1, modulus)
      |> should.equal(Ok(tuple.0 + tuple.1 |> integer.mod(modulus)))
    })

    m.add(tuple.0, tuple.1, -1) |> should.equal(Error(Nil))
    m.add(tuple.0, tuple.1, 0) |> should.equal(Error(Nil))
    m.add(tuple.0, tuple.1, 1) |> should.equal(Error(Nil))
  })
}

pub fn multiply_test() {
  [#(10, 20), #(-10, 20), #(10, -20), #(-10, -20)]
  |> list.each(fn(tuple) {
    list.range(2, 20)
    |> list.each(fn(modulus) {
      m.multiply(tuple.0, tuple.1, modulus)
      |> should.equal(Ok(tuple.0 * tuple.1 |> integer.mod(modulus)))
    })

    m.add(tuple.0, tuple.1, -1) |> should.equal(Error(Nil))
    m.add(tuple.0, tuple.1, 0) |> should.equal(Error(Nil))
    m.add(tuple.0, tuple.1, 1) |> should.equal(Error(Nil))
  })
}

pub fn negate_test() {
  [10, 20, -10, -20]
  |> list.each(fn(number) {
    list.range(2, 20)
    |> list.each(fn(modulus) {
      m.negate(number, modulus)
      |> should.equal(Ok(-number |> integer.mod(modulus)))

      m.add_unsafe(number, m.negate_unsafe(number, modulus), modulus)
      |> should.equal(0)
    })

    m.negate(number, -1) |> should.equal(Error(Nil))
    m.negate(number, 0) |> should.equal(Error(Nil))
    m.negate(number, 1) |> should.equal(Error(Nil))
  })
}

pub fn inv_test() {
  let check_inv = fn(number: Int, modulus: Int) {
    let assert Ok(inv) = m.inv(number, modulus)
    { inv > 0 } |> should.be_true
    { inv < modulus } |> should.be_true
    m.multiply_unsafe(number, inv, modulus) |> should.equal(1)
  }

  [11, 13, 17, 19]
  |> list.each(fn(modulus) {
    list.range(1, modulus - 1)
    |> list.each(fn(number) { check_inv(number, modulus) })
    m.inv(0, modulus) |> should.equal(Error(Nil))
  })

  [1, 3, 7, 9]
  |> list.each(fn(number) { check_inv(number, 10) })
  [0, 2, 4, 5, 6, 8]
  |> list.each(fn(number) { m.inv(number, 10) |> should.equal(Error(Nil)) })

  [1, 5, 7, 11]
  |> list.each(fn(number) { check_inv(number, 12) })
  [0, 2, 3, 4, 6, 8, 9, 10]
  |> list.each(fn(number) { m.inv(number, 12) |> should.equal(Error(Nil)) })

  list.range(0, 20)
  |> list.each(fn(number) {
    m.inv(number, -1) |> should.equal(Error(Nil))
    m.inv(number, 0) |> should.equal(Error(Nil))
    m.inv(number, 1) |> should.equal(Error(Nil))
  })
}

pub fn exp_test() {
  [2938, 69, 199, 592, 41, 99]
  |> list.each(fn(number) {
    [0, 1, 2, 3, 4, 5]
    |> list.each(fn(exp) {
      [2, 3, 4, 5, 29, 30, 31, 32, 33]
      |> list.each(fn(modulus) {
        m.exp(number, exp, modulus)
        |> should.equal(Ok(integer.exp(number, exp) |> integer.mod(modulus)))
      })
    })
  })

  [11, 13, 17, 19]
  |> list.each(fn(modulus) {
    list.range(1, modulus - 1)
    |> list.each(fn(number) {
      m.exp(number, modulus - 1, modulus) |> should.equal(Ok(1))
    })
  })

  m.exp(13, 5, 0) |> should.equal(Error(Nil))
  m.exp(13, 5, -1) |> should.equal(Error(Nil))
  m.exp(13, 0, 0) |> should.equal(Error(Nil))
  m.exp(13, 0, -1) |> should.equal(Error(Nil))
}

pub fn exp_neg_test() {
  let check_exp = fn(number, exp, modulus) {
    m.exp(number, -exp, modulus)
    |> should.equal(m.exp(m.inv_unsafe(number, modulus), exp, modulus))
  }

  [11, 13, 17, 19]
  |> list.each(fn(modulus) {
    list.range(1, modulus - 1)
    |> list.each(fn(number) {
      list.range(0, 5)
      |> list.each(fn(exp) { check_exp(number, exp, modulus) })
    })
  })

  [1, 3, 7, 9]
  |> list.each(fn(number) {
    list.range(0, 5)
    |> list.each(fn(exp) { check_exp(number, exp, 10) })
  })

  [0, 2, 4, 5, 6, 8]
  |> list.each(fn(number) {
    list.range(1, 5)
    |> list.each(fn(exp) { m.exp(number, -exp, 10) |> should.equal(Error(Nil)) })
  })

  [1, 5, 7, 11]
  |> list.each(fn(number) {
    list.range(0, 5)
    |> list.each(fn(exp) { check_exp(number, exp, 12) })
  })

  [0, 2, 3, 4, 6, 8, 9, 10]
  |> list.each(fn(number) {
    list.range(1, 5)
    |> list.each(fn(exp) { m.exp(number, -exp, 12) |> should.equal(Error(Nil)) })
  })

  list.range(0, 20)
  |> list.each(fn(number) {
    m.exp(number, -5, -1) |> should.equal(Error(Nil))
    m.exp(number, -5, 0) |> should.equal(Error(Nil))
    m.exp(number, -5, 1) |> should.equal(Error(Nil))
  })
}

/// Legendre symbol test
pub fn legendre_symbol_test() {
  let prime = 31
  let numbers = list.range(1, 30)
  let squares =
    numbers
    |> list.map(fn(number) { m.multiply_unsafe(number, number, prime) })
    |> list.fold(from: set.new(), with: set.insert)
  numbers
  |> list.each(fn(value) {
    value
    |> m.legendre_symbol(prime)
    |> should.equal(case
      squares
      |> set.contains(value)
    {
      True -> 1
      False -> -1
    })
  })
}

/// Jacobi symbol test
pub fn jacobi_symbol_test() {
  [11, 13, 17, 19]
  |> list.each(fn(prime) {
    list.range(0, prime - 1)
    |> list.each(fn(number) {
      m.jacobi_symbol(number, prime)
      |> should.equal(Ok(m.legendre_symbol(number, prime)))
    })
  })

  let odd = 15
  list.range(0, odd - 1)
  |> list.map(fn(number) { m.jacobi_symbol(number, odd) })
  |> should.equal(
    [0, 1, 1, 0, 1, 0, 0, -1, 1, 0, 0, -1, 0, -1, -1]
    |> list.map(Ok),
  )

  m.jacobi_symbol(13, 30) |> should.equal(Error(Nil))
  m.jacobi_symbol(13, 2) |> should.equal(Error(Nil))
  m.jacobi_symbol(13, -3) |> should.equal(Error(Nil))
}
