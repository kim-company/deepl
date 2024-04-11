defmodule DeeplTest do
  use ExUnit.Case

  test "stubs" do
    client = Req.new(plug: {Req.Test, Deepl})

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

    assert ["DE"] = Deepl.source_languages(client)
  end
end
