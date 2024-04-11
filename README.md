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

## Usage
You can create a Deepl client by calling the `Deepl.new()` function providing the necessary
options, which usually depend on the environment. For testing, you might want to 
use [Req.Test capabilities](https://hexdocs.pm/req/Req.Test.html) and
mock the responses, here is an example

```elixir
# Somewhere in the code you pass these options to the initializatin function
Deepl.new(plug: {Req.Test, Deepl})

# In the test then you can create the appropriate stubs
Req.Test.stub(Deepl, fn conn ->
  case conn.path_info do
    ["v2", "languages"] ->
      Req.Test.json(conn, [
        %{
          language: "DE",
          name: "German",
          supports_formality: true
        }
      ])
  end
end)
```
Refer to Req's guide for more.


In production, you'll want to provide the proper authentication key instead.
```elixir
Deepl.new(auth: "DeepL-Auth-Key #{System.get_env("DEEPL_API_KEY")}")
```

Afterwards, just pass the client to the provided functions:
```elixir
client = Deepl.new(auth: "DeepL-Auth-Key #{System.get_env("DEEPL_API_KEY")}")
translations = Deepl.translate(client, ["Hello, world!"], "IT", source_lang: "EN-US")
```

Note that source_lang is optional.

## Further configuration
Caching is done with ConCache. You can configure its settings with application
environment. Read `application.ex`.



## Copyright and License
Copyright 2024, [KIM Keep In Mind GmbH](https://www.keepinmind.info/)
Licensed under the [Apache License, Version 2.0](LICENSE)
