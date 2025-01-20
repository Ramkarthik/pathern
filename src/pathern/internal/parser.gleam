import gleam/dict
import gleam/string
import pathern/internal/lexer.{type Token}

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
    [head, ..rest] ->
      case parse_token(head, path, params) {
        Ok(#(params, new_path)) -> {
          parse_tokens(rest, new_path, params)
        }
        Error(_) -> Error(Nil)
      }
    [] ->
      case string.is_empty(path) {
        True -> Ok(params)
        False -> Error(Nil)
      }
  }
}

fn parse_token(
  token: Token,
  path: String,
  params: dict.Dict(String, String),
) -> Result(#(dict.Dict(String, String), String), Nil) {
  case token.token_type {
    lexer.Slash | lexer.Literal ->
      case string.slice(path, 0, token.length) {
        "" -> Error(Nil)
        val ->
          case val == token.value {
            True -> Ok(#(params, string.drop_start(path, token.length)))
            False -> Error(Nil)
          }
      }
    lexer.Param -> {
      let param = parse_param(path, "")
      let params = dict.insert(params, token.value, param)
      Ok(#(params, string.drop_start(path, string.length(param))))
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
