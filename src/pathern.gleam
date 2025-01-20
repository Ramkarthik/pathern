/// Pathern - Path to Pattern
/// 
/// Given a path and a single pattern or multiple patterns,
/// the library returns the first matching pattern along with the parameters, if any - Pathern(path: String, pattern: String, params: Dict(String, String))
/// 
/// If there is no match, it returns an Error(Nil)
import gleam/dict.{type Dict}
import pathern/internal/lexer
import pathern/internal/parser

/// A Pathern type is the result if there is a match
/// 
/// It contains the input path, the pattern that matched, and the parameters extraced from the path, if any
pub type Pathern {
  Pathern(path: String, pattern: String, params: Dict(String, String))
}

/// Matches the path against the pattern
/// 
/// Returns either a `Pathern` or an `Error(Nil)`
/// 
/// ## Examples
/// 
/// ```gleam
/// match("/user/jane", "/user/:name")
/// -> Pathern(path: "/user/jane", pattern: "/user/:name", params: [#("name", "jane")])
/// ```
/// 
/// ```gleam
/// match("/user/jane", "/user")
/// -> Error(Nil)
/// ```
/// 
pub fn match(path: String, pattern: String) -> Result(Pathern, Nil) {
  let tokens = lexer.tokenize(pattern, [], 0)
  case parser.parse(path, tokens) {
    Ok(params) -> Ok(Pathern(path, pattern, params))
    Error(_) -> Error(Nil)
  }
}

/// Matches the path against the list of patterns
/// 
/// Returns either a `Pathern` or an `Error(Nil)`
/// 
/// ## Examples
/// 
/// ```gleam
/// match_patterns("/user/jane", ["/user", "/user/:name"])
/// -> Pathern(path: "/user/jane", pattern: "/user/:name", params: [#("name", "jane")])
/// ```
/// 
/// ```gleam
/// match_patterns("/user/jane", ["/user", "/"])
/// -> Error(Nil)
/// ```
/// 
pub fn match_patterns(
  path: String,
  patterns: List(String),
) -> Result(Pathern, Nil) {
  case patterns {
    [head, ..rest] ->
      case match(path, head) {
        Ok(pattern) -> Ok(pattern)
        Error(_) -> match_patterns(path, rest)
      }
    [] -> Error(Nil)
  }
}
