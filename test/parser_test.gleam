import gleam/dict
import gleeunit
import gleeunit/should
import pathern/internal/lexer.{type Token}
import pathern/internal/parser

pub fn main() {
  gleeunit.main()
}

pub fn a_matching_slash_literal_slash_parser_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
  ]
  parser.parse("/user/", tokens)
  |> should.equal(Ok(dict.new()))
}

pub fn a_non_matching_slash_literal_slash_parser_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
  ]
  parser.parse("/uses/", tokens)
  |> should.be_error()
}

pub fn a_non_matching_lenth_slash_literal_slash_parser_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
  ]
  parser.parse("/users/", tokens)
  |> should.be_error()
}

pub fn a_matching_slash_literal_slash_param_parser_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Literal, 4, 4, "user") },
    { lexer.Token(lexer.Slash, 5, 1, "/") },
    { lexer.Token(lexer.Param, 10, 5, "name") },
  ]
  parser.parse("/user/jane", tokens)
  |> should.equal(Ok(dict.from_list([#("name", "jane")])))
}

pub fn a_matching_slash_param_slash_param_parser_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Param, 3, 3, "id") },
    { lexer.Token(lexer.Slash, 4, 1, "/") },
    { lexer.Token(lexer.Param, 9, 5, "name") },
  ]
  parser.parse("/123456/james", tokens)
  |> should.equal(Ok(dict.from_list([#("id", "123456"), #("name", "james")])))
}

pub fn a_non_matching_slash_param_slash_literal_parser_test() {
  let tokens: List(Token) = [
    { lexer.Token(lexer.Slash, 0, 1, "/") },
    { lexer.Token(lexer.Param, 5, 5, "name") },
    { lexer.Token(lexer.Slash, 6, 1, "/") },
    { lexer.Token(lexer.Literal, 10, 4, "users") },
  ]
  parser.parse("/jane/users", tokens)
  |> should.be_error()
}
