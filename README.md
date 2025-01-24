# Pathern (path + pattern)
[![Package Version](https://img.shields.io/hexpm/v/pathern)](https://hex.pm/packages/pathern)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/pathern/)

A URL path pattern matching library for the Gleam programming language.

## Installation

```
gleam add pathern@0.1.1

```


## Usage

```gleam
import gleeunit/should
import pathern

pub fn main() {

  // Path parameter match
  // path: "/user/juliet"
  // pattern: "/user/:name"
  //
  // returns: (path: "/user/juliet", pattern: "/user/:name", params: [#("name", "juliet")])
  pathern.match("/user/juliet", "/user/:name")
  |> should.equal(
    Ok(pathern.Pathern(
      "/user/juliet",
      "/user/:name",
      dict.from_list([#("name", "juliet")]),
    )),
  )

  // Path parameter without match
  // path: "/user/juliet"
  // pattern: "/create/:name"
  //
  // returns: Error(Nil)
  pathern.match("/user/juliet", "/create/:name")
  |> should.be_error()

  // Path parameter match against a list of patterns
  // path: "/user/juliet/123"
  // patterns: ["/", "/user", "/name", "/user/:name/:id"]
  //
  // returns: (path: "/user/juliet", pattern: "/user/:name", params: [#("name", "juliet"), #("id", "123")])
  pathern.match_patterns("/user/juliet/123", ["/", "/user", "/name", "/user/:name/:id"])
  |> should.equal(
    Ok(pathern.Pathern(
      "/user/juliet/123",
      "/user/:name/:id",
      dict.from_list([#("name", "juliet"), #("id", "123")]),
    )),
  )

  // Path parameter without a match against a list of patterns
  // path: "/user/juliet"
  // patterns: ["/", "/user", "/name", "/list/:name"]
  //
  // returns: Error(Nil)
  pathern.match_patterns("/user/juliet", ["/", "/user", "/name", "/list/:name"])
  |> should.be_error()

}
```

Further documentation can be found at <https://hexdocs.pm/pathern>.

## Patterns supported

[x] Root (`"/"`)

[x] Exact path (`"/user/"`)

[x] Path parameters (`"/user/:name/"`)

[ ] Optional parameter (`"/user/:name?/"`)

[x] Wildcard (`"/user/*"`)

[ ] Regex (`"/user/:id{[0-9]+}/"`)

[ ] Query string (`"/user?id={:id}"`)
