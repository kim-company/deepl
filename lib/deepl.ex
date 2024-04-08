defmodule Deepl do
  defmodule Error do
    defexception [:message]

    @impl true
    def exception(response) do
      message = Map.get(response.body, "message", "undefined")
      message = "Failed with status #{response.status}: #{inspect(message)}"
      %__MODULE__{message: message}
    end
  end

  @connect_timeout 3_000
  @receive_timeout 3_000

  @spec translate([String.t()], String.t(), Keyword.t()) :: [String.t()]
  def translate(sentences, target_lang, opts \\ []) do
    opts
    |> new()
    |> post(sentences, target_lang, opts)
  end

  @type language_type :: :target | :source

  @spec supported_languages(language_type()) :: [map()]
  def supported_languages(type \\ :target) do
    get_fun = fn ->
      response =
        []
        |> new()
        |> Req.get!(url: "/languages", params: [type: type])

      if response.status == 200 do
        response.body
      else
        raise Deepl.Error, response
      end
    end

    key = Enum.join(["supported", "languages", type], "-")
    ConCache.get_or_store(Deepl.Cache, key, get_fun)
  end

  @spec new(Keyword.t()) :: Req.Request.t()
  defp new(opts) do
    auth_key = Application.get_env(:deepl, :auth_key, "")

    if auth_key == "" do
      raise RuntimeError, "Could not find :auth_key in application environment"
    end

    endpoint = Application.get_env(:deepl, :endpoint, "api.deepl.com")
    base_url = URI.new!("https://#{endpoint}/v2/")

    connect_timeout = Keyword.get(opts, :connect_timeout, @connect_timeout)
    receive_timeout = Keyword.get(opts, :receive_timeout, @receive_timeout)

    Req.new(
      base_url: base_url,
      connect_options: [timeout: connect_timeout],
      receive_timeout: receive_timeout,
      auth: "DeepL-Auth-Key #{auth_key}"
    )
  end

  @spec post(Req.Request.t(), [String.t()], String.t(), Keyword.t()) :: [String.t()]
  defp post(req, sentences, target_lang, opts) do
    source_lang = Keyword.get(opts, :source_lang, "")
    cache = Keyword.get(opts, :cache, true)

    get_fun = fn ->
      response =
        Req.post!(req,
          url: "/translate",
          json: %{
            text: sentences,
            source_lang: source_lang,
            target_lang: target_lang
          }
        )

      if response.status != 200 do
        raise Deepl.Error, response
      else
        response.body
        |> Map.fetch!("translations")
        |> Enum.map(&Map.fetch!(&1, "text"))
      end
    end

    if cache do
      key = generate_hash([target_lang, source_lang | sentences])
      ConCache.get_or_store(Deepl.Cache, key, get_fun)
    else
      get_fun.()
    end
  end

  defp generate_hash(fields) do
    fields
    |> Enum.reduce(:crypto.hash_init(:sha), fn data, hash ->
      :crypto.hash_update(hash, data)
    end)
    |> :crypto.hash_final()
    |> Base.encode16()
  end
end
