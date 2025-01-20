import gleeunit
import gleeunit/should
import pathern/internal/lexer.{type Token}

pub fn main() {
  gleeunit.main()
}

pub fn a_single_escaped_token_test() {
  let tokens: List(Token) = [{ lexer.Token(lexer.Slash, 0, 1, "/") }]
  lexer.tokenize("/", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_literal_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
  ]
  lexer.tokenize("/user", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_literal_slash_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 5, 5, "users") },
    { lexer.Token(lexer.Slash, 6, 1, "/") },
  ]
  lexer.tokenize("/users/", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_literal_slash_literal_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
    { lexer.Token(lexer.Literal, 9, 4, "john") },
  ]
  lexer.tokenize("/user/john", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_param_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Param, 5, 5, "name") },
  ]
  lexer.tokenize("/:name", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_param_slash_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Param, 5, 5, "name") },
    { lexer.Token(lexer.Slash, 6, 1, "/") },
  ]
  lexer.tokenize("/:name/", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_literal_slash_param_slash_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
    { lexer.Token(lexer.Param, 10, 5, "name") },
    { lexer.Token(lexer.Slash, 11, 1, "/") },
  ]
  lexer.tokenize("/user/:name/", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_optional_param_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.OptionalParam, 6, 6, "name") },
  ]
  lexer.tokenize("/:name?", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_literal_slash_optional_param_slash_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
    { lexer.Token(lexer.OptionalParam, 11, 6, "name") },
    { lexer.Token(lexer.Slash, 12, 1, "/") },
  ]
  lexer.tokenize("/user/:name?/", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_literal_slash_wildcard_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
    { lexer.Token(lexer.Wildcard, 6, 1, "*") },
  ]
  lexer.tokenize("/user/*", [], 0)
  |> should.equal(tokens)
}

pub fn a_slash_wildcard_slash_literal_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Wildcard, 1, 1, "*") },
    { lexer.Token(lexer.Slash, 2, 1, "/") },
    { lexer.Token(lexer.Literal, 6, 4, "user") },
  ]
  lexer.tokenize("/*/user", [], 0)
  |> should.equal(tokens)
}
