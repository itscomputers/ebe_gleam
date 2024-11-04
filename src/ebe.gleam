import argv
import clip
import clip/arg
import clip/help
import ebe/primality
import gleam/int
import gleam/io
import gleam/string

type Args {
  Args(function: String, arguments: List(String))
}

fn int_arg(arg: String) -> Result(Int, String) {
  case int.base_parse(arg, 10) {
    Error(Nil) -> Error("cannot parse " <> arg <> " as an integer")
    Ok(number) -> Ok(number)
  }
}

fn preamble(res: Result(Args, String)) {
  case res {
    Ok(args) -> {
      io.println(
        "running "
        <> args.function
        <> "("
        <> args.arguments |> string.join(", ")
        <> ")",
      )
      res
    }
    _ -> res
  }
}

fn handle_single_argument(
  function: fn(Int) -> a,
  arg: String,
) -> Result(String, String) {
  case arg |> int_arg {
    Ok(number) -> number |> function |> string.inspect |> Ok
    Error(e) -> Error(e)
  }
}

fn handle_two_arguments(
  function: fn(Int, Int) -> a,
  arg1: String,
  arg2: String,
) -> Result(String, String) {
  case int_arg(arg1), int_arg(arg2) {
    Ok(n1), Ok(n2) -> function(n1, n2) |> string.inspect |> Ok
    Error(e), Ok(_) -> Error(e)
    Ok(_), Error(e) -> Error(e)
    Error(e1), Error(e2) -> Error(e1 <> ", " <> e2)
  }
}

fn build_display(args: Result(Args, String)) -> Result(String, String) {
  io.println("")
  case args |> preamble {
    Ok(Args("primes_before", [arg])) ->
      primality.primes_before |> handle_single_argument(arg)
    Ok(Args("is_prime", [arg])) ->
      primality.is_prime |> handle_single_argument(arg)
    Ok(Args("primes_in_range", [arg1, arg2])) ->
      primality.primes_in_range |> handle_two_arguments(arg1, arg2)
    Ok(args) ->
      { "error: unsupported function: " <> { args |> string.inspect } } |> Ok
    Error(e) -> Error(e)
  }
}

fn show_display(display: Result(String, String)) {
  case display {
    Ok(s) -> {
      s |> io.println
    }
    Error(s) -> {
      { "error: " <> s } |> io.println
    }
  }
}

fn command() {
  clip.command(fn(function) { fn(arguments) { Args(function, arguments) } })
  |> clip.arg(arg.new("function") |> arg.help("function"))
  |> clip.arg_many(arg.new("arguments") |> arg.help("arguments"))
}

pub fn main() {
  command()
  |> clip.help(help.simple("ebe CLI", "access ebe functionality"))
  |> clip.run(argv.load().arguments)
  |> build_display
  |> show_display
}
