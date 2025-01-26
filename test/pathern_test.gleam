import gleam/dict
import gleeunit
import gleeunit/should
import pathern
import pathern/internal/parser

pub fn main() {
  gleeunit.main()
}

pub fn empty_pattern_list_test() {
  pathern.match_patterns("/", [])
  |> should.be_error()
}

pub fn matching_root_without_slash_pattern_test() {
  pathern.match("", "/")
  |> should.equal(Ok(pathern.Pathern("", "/", dict.new())))
}

pub fn matching_root_pattern_test() {
  pathern.match("/", "/")
  |> should.equal(Ok(pathern.Pathern("/", "/", dict.new())))
}

pub fn matching_root_pattern_list_test() {
  pathern.match_patterns("/", ["/"])
  |> should.equal(Ok(pathern.Pathern("/", "/", dict.new())))
}

pub fn matching_literal_pattern_test() {
  pathern.match("/name", "/name")
  |> should.equal(Ok(pathern.Pathern("/name", "/name", dict.new())))
}

pub fn non_matching_literal_pattern_test() {
  pathern.match("/name", "/")
  |> should.be_error()
}

pub fn matching_literal_pattern_list_test() {
  pathern.match_patterns("/name", ["/", "/user", "/name", "/create"])
  |> should.equal(Ok(pathern.Pathern("/name", "/name", dict.new())))
}

pub fn non_matching_literal_pattern_list_test() {
  pathern.match_patterns("/name", ["/", "/user", "/create"])
  |> should.be_error()
}

pub fn matching_literal_param_pattern_test() {
  pathern.match("/user/juliet", "/user/:name")
  |> should.equal(
    Ok(pathern.Pathern(
      "/user/juliet",
      "/user/:name",
      dict.from_list([#("name", "juliet")]),
    )),
  )
}

pub fn non_matching_literal_param_pattern_test() {
  pathern.match("/user/juliet", "/users/:name/")
  |> should.be_error()
}

pub fn matching_literal_param_pattern_list_test() {
  pathern.match_patterns("/user/juliet", ["/", "/user", "/name", "/user/:name/"])
  |> should.equal(
    Ok(pathern.Pathern(
      "/user/juliet",
      "/user/:name/",
      dict.from_list([#("name", "juliet")]),
    )),
  )
}

pub fn non_matching_literal_param_pattern_list_test() {
  pathern.match_patterns("/user/juliet", ["/", "/user", "/name", "/users/:name"])
  |> should.be_error()
}

pub fn matching_param_literal_param_pattern_test() {
  pathern.match("/1234/user/juliet/", "/:id/user/:name")
  |> should.equal(
    Ok(pathern.Pathern(
      "/1234/user/juliet/",
      "/:id/user/:name",
      dict.from_list([#("id", "1234"), #("name", "juliet")]),
    )),
  )
}

pub fn matching_param_literal_param_pattern_list_test() {
  pathern.match_patterns("/1234/user/juliet", [
    "/", "/user", "/name", "/:id/user/:name", "/user/:name",
  ])
  |> should.equal(
    Ok(pathern.Pathern(
      "/1234/user/juliet",
      "/:id/user/:name",
      dict.from_list([#("id", "1234"), #("name", "juliet")]),
    )),
  )
}

pub fn matching_wildcard_pattern_test() {
  pathern.match("/create", "/*")
  |> should.equal(Ok(pathern.Pathern("/create", "/*", dict.new())))
}

pub fn matching_wildcard_pattern_list_test() {
  pathern.match_patterns("/create", [
    "/", "/user", "/name", "/:id/user/:name", "/user/:name", "/*",
  ])
  |> should.equal(Ok(pathern.Pathern("/create", "/*", dict.new())))
}

pub fn matching_wildcard_literal_pattern_test() {
  pathern.match("/create/user", "/*/user")
  |> should.equal(Ok(pathern.Pathern("/create/user", "/*/user", dict.new())))

  pathern.match("/create/user", "/*user")
  |> should.equal(Ok(pathern.Pathern("/create/user", "/*user", dict.new())))
}

pub fn matching_wildcard_literal_pattern_list_test() {
  pathern.match_patterns("/create/user", [
    "/", "/user", "/name", "/:id/user/:name", "/creat*", "/create*",
  ])
  |> should.equal(Ok(pathern.Pathern("/create/user", "/creat*", dict.new())))
}

pub fn pattern_error_optional_param_pattern_test() {
  let res = pathern.match("/12345/", "/:id?user")
  case res {
    Ok(_) -> False
    Error(error) ->
      case error {
        parser.PatternError(_) -> True
        _ -> False
      }
  }
}

pub fn matching_optional_param_pattern_test() {
  pathern.match_patterns("/12345/", [
    "/", "/user", "/name", "/:id?", "/creat*", "/create*",
  ])
  |> should.equal(
    Ok(pathern.Pathern("/12345/", "/:id?", dict.from_list([#("id", "12345")]))),
  )
}

pub fn matching_optional_param_literal_pattern_test() {
  pathern.match_patterns("/12345/user", [
    "/", "/user", "/name", "/:id?/user", "/creat*", "/create*",
  ])
  |> should.equal(
    Ok(pathern.Pathern(
      "/12345/user",
      "/:id?/user",
      dict.from_list([#("id", "12345")]),
    )),
  )
}

pub fn matching_optional_param_without_one_test() {
  pathern.match("/user", "/:id?/user")
  |> should.equal(Ok(pathern.Pathern("/user", "/:id?/user", dict.new())))

  pathern.match("/user/", "/user/:id?")
  |> should.equal(Ok(pathern.Pathern("/user/", "/user/:id?", dict.new())))
}
