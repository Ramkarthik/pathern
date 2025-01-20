# Pathern (path + pattern)

A URL path pattern matching library for the Gleam programming language.

## Installation

```
gleam add pathern@0.0.1

```


## Usage

```gleam
import gleeunit/should
import pathern

pub fn main() {

  // Path parameter match
  pathern.match("/user/juliet", "/user/:name")
  |> should.equal(
    Ok(pathern.Pathern(
      "/user/juliet",
      "/user/:name",
      dict.from_list([#("name", "juliet")]),
    )),
  )

  // Path parameter without match
  pathern.match("/user/juliet", "/create/:name")
  |> should.be_error()

  // Path parameter match against a list of patterns
  pathern.match_patterns("/user/juliet", ["/", "/user", "/name", "/user/:name"])
  |> should.equal(
    Ok(pathern.Pathern(
      "/user/juliet",
      "/user/:name",
      dict.from_list([#("name", "juliet")]),
    )),
  )

  // Path parameter without a match against a list of patterns
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

[ ] Wildcard (`"/user/*"`)

[ ] Regex (`"/user/:id{[0-9]+}/"`)

[ ] Query string (`"/user?id={:id}"`)
