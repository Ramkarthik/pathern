import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import pathern/internal/lexer.{type Token, Literal, Param, Slash, Wildcard}

pub fn parse(
  path: String,
  tokens: List(Token),
) -> Result(dict.Dict(String, String), Nil) {
  let params: dict.Dict(String, String) = dict.new()
  parse_tokens(tokens, path, params)
}

fn parse_tokens(
  tokens: List(Token),
  path: String,
  params: dict.Dict(String, String),
) -> Result(dict.Dict(String, String), Nil) {
  case tokens {
    [token] if token.token_type == Slash ->
      case path == "/" || path == "" {
        True -> Ok(params)
        False -> Error(Nil)
      }
    [head, ..rest] ->
      case parse_token(head, first_or_none(rest), path, params) {
        Ok(#(params, new_path)) -> {
          parse_tokens(rest, new_path, params)
        }
        Error(_) -> Error(Nil)
      }
    [] -> {
      case string.is_empty(path) || path == "/" {
        True -> Ok(params)
        False -> Error(Nil)
      }
    }
  }
}

fn parse_token(
  token: Token,
  next_token: Option(Token),
  path: String,
  params: dict.Dict(String, String),
) -> Result(#(dict.Dict(String, String), String), Nil) {
  case token.token_type {
    Slash | Literal ->
      case string.slice(path, 0, token.length) {
        "" -> Error(Nil)
        val ->
          case val == token.value {
            True -> Ok(#(params, string.drop_start(path, token.length)))
            False -> Error(Nil)
          }
      }
    Param -> {
      let param = parse_param(path, "")
      let params = dict.insert(params, token.value, param)
      Ok(#(params, string.drop_start(path, string.length(param))))
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
                Error(_) -> Error(Nil)
              }
            Literal ->
              case
                find_literal(string.drop_start(path, 1), next_token.value, 0, 0)
              {
                Ok(index) -> Ok(#(params, string.drop_start(path, index + 1)))
                Error(_) -> Error(Nil)
              }
            _ -> Ok(#(params, ""))
          }
        None -> Ok(#(params, ""))
      }
    }
    _ -> Error(Nil)
  }
}

fn parse_param(path: String, accum: String) -> String {
  case string.first(path) {
    Ok(grapheme) ->
      case grapheme {
        "/" -> accum
        _ -> parse_param(string.drop_start(path, 1), accum <> grapheme)
      }
    Error(_) -> accum
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
) -> Result(Int, Nil) {
  let literal_length = string.length(literal)
  case string.first(path) {
    Ok(grapheme) -> {
      case match_literal_grapheme(grapheme, literal, checking_index) {
        Ok(_) if literal_length == checking_index + 1 -> Ok(index)
        Ok(_) ->
          find_literal(
            string.drop_start(path, 1),
            literal,
            checking_index + 1,
            index,
          )
        Error(_) ->
          find_literal(string.drop_start(path, 1), literal, 0, index + 1)
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
