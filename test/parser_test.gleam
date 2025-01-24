import gleam/dict
import gleeunit
import gleeunit/should
import pathern/internal/lexer.{
  type Token, Literal, Param, Slash, Token, Wildcard,
}
import pathern/internal/parser

pub fn main() {
  gleeunit.main()
}

pub fn a_matching_slash_literal_slash_parser_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Literal, 4, 4, "user") },
    { Token(Slash, 5, 1, "/") },
  ]
  parser.parse("/user/", tokens)
  |> should.equal(Ok(dict.new()))
}

pub fn a_non_matching_slash_literal_slash_parser_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Literal, 4, 4, "user") },
    { Token(Slash, 5, 1, "/") },
  ]
  parser.parse("/uses/", tokens)
  |> should.be_error()
}

pub fn a_non_matching_lenth_slash_literal_slash_parser_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Literal, 4, 4, "user") },
    { Token(Slash, 5, 1, "/") },
  ]
  parser.parse("/users/", tokens)
  |> should.be_error()
}

pub fn a_matching_slash_literal_slash_param_parser_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Literal, 4, 4, "user") },
    { Token(Slash, 5, 1, "/") },
    { Token(Param, 10, 5, "name") },
  ]
  parser.parse("/user/jane", tokens)
  |> should.equal(Ok(dict.from_list([#("name", "jane")])))
}

pub fn a_matching_slash_param_slash_param_parser_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Param, 3, 3, "id") },
    { Token(Slash, 4, 1, "/") },
    { Token(Param, 9, 5, "name") },
  ]
  parser.parse("/123456/james", tokens)
  |> should.equal(Ok(dict.from_list([#("id", "123456"), #("name", "james")])))
}

pub fn a_non_matching_slash_param_slash_literal_parser_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Param, 5, 5, "name") },
    { Token(Slash, 6, 1, "/") },
    { Token(Literal, 10, 4, "users") },
  ]
  parser.parse("/jane/users", tokens)
  |> should.be_error()
}

pub fn a_matching_slash_wildcard_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Wildcard, 1, 1, "*") },
  ]
  parser.parse("/name", tokens)
  |> should.equal(Ok(dict.new()))
}

pub fn a_matching_slash_literal_slash_wildcard_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Literal, 4, 4, "user") },
    { Token(Slash, 5, 1, "/") },
    { Token(Wildcard, 6, 1, "*") },
  ]
  parser.parse("/user/name", tokens)
  |> should.equal(Ok(dict.new()))
}

pub fn a_matching_slash_wildcard_literal_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Wildcard, 1, 1, "*") },
    { Token(Literal, 2, 4, "user") },
  ]
  parser.parse("/useuser", tokens)
  |> should.equal(Ok(dict.new()))
}

pub fn a_matching_slash_wildcard_slash_literal_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Wildcard, 1, 1, "*") },
    { Token(Slash, 2, 1, "/") },
    { Token(Literal, 3, 4, "user") },
  ]
  parser.parse("/create/user", tokens)
  |> should.equal(Ok(dict.new()))
}

pub fn a_matching_slash_wildcard_slash_param_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Wildcard, 1, 1, "*") },
    { Token(Slash, 2, 1, "/") },
    { Token(Param, 3, 5, "name") },
  ]
  parser.parse("/user/james", tokens)
  |> should.equal(Ok(dict.from_list([#("name", "james")])))
}

pub fn a_matching_slash_param_slash_wildcard_test() {
  let tokens: List(Token) = [
    { Token(Slash, 0, 1, "/") },
    { Token(Param, 1, 4, "name") },
    { Token(Slash, 6, 1, "/") },
    { Token(Wildcard, 7, 1, "*") },
  ]
  parser.parse("/james/12345", tokens)
  |> should.equal(Ok(dict.from_list([#("name", "james")])))
}
