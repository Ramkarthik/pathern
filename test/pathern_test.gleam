import gleam/dict
import gleeunit
import gleeunit/should
import pathern

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
