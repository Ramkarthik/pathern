import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import pathern/internal/lexer.{
  type Token, Literal, OptionalParam, Param, Slash, Wildcard,
}

pub type ParseError {
  MatchError
  PatternError(message: String)
  PatternNotSupportedError(message: String)
}

pub fn parse(
  path: String,
  tokens: List(Token),
) -> Result(dict.Dict(String, String), ParseError) {
  let params: dict.Dict(String, String) = dict.new()
  parse_tokens(tokens, path, params)
}

fn parse_tokens(
  tokens: List(Token),
  path: String,
  params: dict.Dict(String, String),
) -> Result(dict.Dict(String, String), ParseError) {
  case tokens {
    [token] if token.token_type == Slash ->
      case path == "/" || path == "" {
        True -> Ok(params)
        False -> Error(MatchError)
      }
    [head, ..rest] ->
      case parse_token(head, rest, path, params) {
        Ok(#(params, new_path)) -> {
          parse_tokens(rest, new_path, params)
        }
        Error(error) -> Error(error)
      }
    [] -> {
      case string.is_empty(path) || path == "/" {
        True -> Ok(params)
        False -> Error(MatchError)
      }
    }
  }
}

fn parse_token(
  token: Token,
  rest: List(Token),
  path: String,
  params: dict.Dict(String, String),
) -> Result(#(dict.Dict(String, String), String), ParseError) {
  let next_token = first_or_none(rest)
  case token.token_type {
    Slash | Literal ->
      case parse_literal(path, token) {
        Ok(new_path) -> Ok(#(params, new_path))
        Error(error) -> Error(error)
      }
    Param -> {
      let param = parse_param(path, "")
      let params = dict.insert(params, token.value, param)
      Ok(#(params, string.drop_start(path, string.length(param))))
    }
    OptionalParam -> {
      case rest {
        [rest_first, rest_second, ..] -> {
          case rest_first.token_type {
            Slash -> {
              case rest_second.token_type {
                Literal -> {
                  case parse_optional_param(path, "", rest_second) {
                    Ok(val) -> {
                      case string.is_empty(val) {
                        True ->
                          Ok(#(
                            params,
                            string.drop_start(path, string.length(val)),
                          ))
                        False -> {
                          let params = dict.insert(params, token.value, val)
                          Ok(#(
                            params,
                            string.drop_start(path, string.length(val)),
                          ))
                        }
                      }
                    }
                    Error(_error) -> {
                      Ok(#(params, "/" <> path))
                    }
                  }
                }
                _ ->
                  Error(PatternNotSupportedError(
                    message: "Expected a `literal` after the optional parameter and a `/`",
                  ))
              }
            }
            _ ->
              Error(PatternError(
                message: "Expected a `/` after the optional parameter but received `"
                <> rest_first.value
                <> "`",
              ))
          }
        }
        [rest] -> {
          case rest.token_type {
            Slash -> {
              let param = parse_param(path, "")
              let params = dict.insert(params, token.value, param)
              Ok(#(params, string.drop_start(path, string.length(param))))
            }
            _ -> {
              Error(PatternError(
                message: "Expected a `/` after the optional parameter but received `"
                <> rest.value
                <> "`",
              ))
            }
          }
        }
        [] -> {
          let param = parse_param(path, "")
          case string.is_empty(param) {
            True -> Ok(#(params, string.drop_start(path, string.length(param))))
            False -> {
              let params = dict.insert(params, token.value, param)
              Ok(#(params, string.drop_start(path, string.length(param))))
            }
          }
        }
      }
    }
    Wildcard -> {
      case next_token {
        Some(next_token) ->
          case next_token.token_type {
            Slash ->
              case find_slash(path, 0) {
                Ok(index) -> {
                  Ok(#(params, string.drop_start(path, index)))
                }
                Error(_) -> Error(MatchError)
              }
            Literal ->
              case
                find_literal(
                  string.drop_start(path, 1),
                  next_token.value,
                  0,
                  0,
                  string.first(path),
                  False,
                )
              {
                Ok(#(index, _value)) -> {
                  Ok(#(params, string.drop_start(path, index + 1)))
                }
                Error(_) -> Error(MatchError)
              }
            _ -> Ok(#(params, ""))
          }
        None -> Ok(#(params, ""))
      }
    }
    _ -> Error(MatchError)
  }
}

fn parse_param(path path: String, accum accum: String) -> String {
  case string.first(path) {
    Ok(grapheme) ->
      case grapheme {
        "/" -> accum
        _ -> parse_param(string.drop_start(path, 1), accum <> grapheme)
      }
    Error(_) -> accum
  }
}

fn parse_optional_param(
  path path: String,
  accum accum: String,
  literal token: Token,
) -> Result(String, ParseError) {
  case string.first(path) {
    Ok(grapheme) ->
      case grapheme {
        "/" ->
          case parse_literal(string.drop_start(path, 1), token) {
            Ok(_) -> Ok(accum)
            Error(error) -> Error(error)
          }
        _ ->
          parse_optional_param(
            string.drop_start(path, 1),
            accum <> grapheme,
            token,
          )
      }
    Error(_) -> Error(MatchError)
  }
}

fn parse_literal(
  path path: String,
  literal token: Token,
) -> Result(String, ParseError) {
  case string.slice(path, 0, token.length) {
    "" -> Error(MatchError)
    val ->
      case val == token.value {
        True -> Ok(string.drop_start(path, string.length(token.value)))
        False -> Error(MatchError)
      }
  }
}

fn first_or_none(items: List(t)) -> Option(t) {
  case list.first(items) {
    Ok(item) -> Some(item)
    Error(_) -> None
  }
}

fn find_slash(path: String, index: Int) -> Result(Int, Nil) {
  case string.first(path) {
    Ok("/") -> Ok(index)
    Ok(_) -> find_slash(string.drop_start(path, 1), index + 1)
    Error(_) -> Error(Nil)
  }
}

fn find_literal(
  path path: String,
  literal literal: String,
  checking_index checking_index: Int,
  index index: Int,
  value value: Result(String, Nil),
  check_slash check_slash: Bool,
) -> Result(#(Int, String), Nil) {
  let literal_length = string.length(literal)
  let value = case value {
    Ok(v) -> v
    Error(_) -> ""
  }
  case string.first(path) {
    Ok(grapheme) -> {
      case match_literal_grapheme(grapheme, literal, checking_index) {
        Ok(_) if literal_length == checking_index + 1 ->
          Ok(#(index, value <> grapheme))
        Ok(_) ->
          find_literal(
            string.drop_start(path, 1),
            literal,
            checking_index + 1,
            index,
            Ok(value <> grapheme),
            check_slash,
          )
        Error(_) ->
          find_literal(
            string.drop_start(path, 1),
            literal,
            0,
            index + 1,
            Ok(value <> grapheme),
            check_slash,
          )
      }
    }
    Error(_) -> Error(Nil)
  }
}

fn match_literal_grapheme(
  grapheme: String,
  literal: String,
  checking_index: Int,
) -> Result(Nil, Nil) {
  case string.first(string.drop_start(literal, checking_index)) {
    Ok(literal_grapheme) if literal_grapheme == grapheme -> Ok(Nil)
    Ok(_) -> Error(Nil)
    Error(_) -> Error(Nil)
  }
}
