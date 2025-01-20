import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type TokenType {
  LeftBrace
  RightBrace
  Wildcard
  Param
  OptionalParam
  LeftParen
  RightParen
  Question
  Slash
  Literal
}

pub type Token {
  Token(token_type: TokenType, index: Int, length: Int, value: String)
}

pub fn tokenize(
  pattern: String,
  tokens: List(Token),
  current: Int,
) -> List(Token) {
  case is_end(pattern) {
    True -> tokens
    False -> {
      case parse(pattern, current, "", None) {
        Some(token) -> {
          let tokens = list.append(tokens, [token])

          tokenize(
            string.drop_start(pattern, token.length),
            tokens,
            token.index + 1,
          )
        }
        None -> tokens
      }
    }
  }
}

fn parse(
  pattern: String,
  current: Int,
  value: String,
  token: Option(Token),
) -> Option(Token) {
  case string.first(pattern) {
    Ok(grapheme) -> {
      case grapheme {
        "/" -> {
          case token {
            Some(token) -> Some(token)
            None ->
              Some(Token(
                token_type: Slash,
                index: current,
                length: 1,
                value: grapheme,
              ))
          }
        }
        "*" -> {
          case token {
            Some(token) -> Some(token)
            None ->
              Some(Token(
                token_type: Wildcard,
                index: current,
                length: 1,
                value: grapheme,
              ))
          }
        }
        ":" -> {
          case parse_param(string.drop_start(pattern, 1), current + 1, "") {
            Some(token) -> {
              parse(
                string.drop_start(pattern, token.length),
                current + 1,
                token.value,
                Some(token),
              )
            }
            None -> None
          }
        }
        _ -> {
          let value = value <> grapheme
          parse(
            string.drop_start(pattern, 1),
            current + 1,
            value,
            Some(Token(
              token_type: Literal,
              index: current,
              length: string.length(value),
              value: value,
            )),
          )
        }
      }
    }
    Error(_) -> token
  }
}

fn parse_param(pattern: String, current: Int, value: String) -> Option(Token) {
  case string.first(pattern) {
    Ok(grapheme) ->
      case grapheme {
        "/" -> {
          Some(Token(Param, current - 1, string.length(value) + 1, value))
        }
        "?" -> {
          Some(Token(OptionalParam, current, string.length(value) + 2, value))
        }
        _ ->
          parse_param(
            string.drop_start(pattern, 1),
            current + 1,
            value <> grapheme,
          )
      }
    Error(_) ->
      case string.is_empty(value) {
        True -> None
        False ->
          Some(Token(Param, current - 1, string.length(value) + 1, value))
      }
  }
}

fn is_end(input: String) -> Bool {
  case string.first(input) {
    Ok(_) -> False
    Error(_) -> True
  }
}
