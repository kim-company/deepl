# Deepl
Batteries-included Elixir library for dealing with Deepl API. With batteries I mean caching.

## Installation
```elixir
def deps do
  [
    {:deepl, github: "kim-company/deepl"}
  ]
end
```

## Configuration
In production you're going to want to set the endpoint and auth environment variables

```elixir
# config/runtime.exs
config :deepl, req_options: [
  auth: "DeepL-Auth-Key #{System.get_env("DEEPL_API_KEY")}",
  connect_options: [timeout: 3_000]
]
```
Check https://hexdocs.pm/req/Req.html#new/1 for all available options.

During tests, you can instead use [Req.Test capabilities](https://hexdocs.pm/req/Req.Test.html) and
mock the responses.

```elixir
# config/test.exs
config :deepl, req_options: [
  plug: {Req.Test, Fake.Deepl.Plug}
]
```

## Copyright and License
Copyright 2024, [KIM Keep In Mind GmbH](https://www.keepinmind.info/)
Licensed under the [Apache License, Version 2.0](LICENSE)
