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

  @type t :: Req.Request.t()

  @spec source_languages(t()) :: [String.t()]
  def source_languages(req), do: supported_languages(req, :source)

  @spec target_languages(t()) :: [String.t()]
  def target_languages(req), do: supported_languages(req, :target)

  @spec new(keyword()) :: t()
  def new(opts) do
    opts
    |> Keyword.put_new(:base_url, "https://api.deepl.com/")
    |> Req.new()
  end

  @spec translate(Req.Request.t(), [String.t()], String.t(), Keyword.t()) :: [String.t()]
  def translate(req, sentences, target_lang, opts \\ []) do
    source_lang = Keyword.get(opts, :source_lang, "")
    cache = Keyword.get(opts, :cache, true)

    get_fun = fn ->
      response =
        Req.post!(req,
          url: "/v2/translate",
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

  defp supported_languages(req, type) do
    get_fun = fn ->
      response = Req.get!(req, url: "/v2/languages", params: [type: type])

      if response.status == 200 do
        codes = Enum.map(response.body, fn %{"language" => x} -> x end)

        # As of January 2024, Arabic (AR) is supported as a source and target language for text translation, but it is not yet supported for document translation.
        # Therefore, Arabic has not yet been added to the /languages endpoint.
        Enum.uniq(["AR" | codes])
      else
        raise Deepl.Error, response
      end
    end

    key = Enum.join(["supported", "languages", type], "-")
    ConCache.get_or_store(Deepl.Cache, key, get_fun)
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
