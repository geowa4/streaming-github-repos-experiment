defmodule GitHub do
  use HTTPoison.Base

  @moduledoc """
  GitHub API
  """

  @endpoint "https://api.github.com"

  defp process_url(path) do
    if String.starts_with?(path, @endpoint) do
      path
    else
      @endpoint <> path
    end
  end

  defp process_link_header(nil), do: %{}
  defp process_link_header(link_header) do
    link_header
    |> String.split(~r/,\s/)
    |> Enum.map(fn(link) ->
         [_, name] = Regex.run(~r/rel="([a-z]+)"/, link)
         [_, url] = Regex.run(~r/<([^>]+)>/, link)
         {name, url}
       end)
    |> Map.new
  end

  def process_headers(headers) do
    headers = Map.new(headers)
    link_map = headers
    |> Map.get("Link")
    |> process_link_header
    Map.put(headers, "Link", link_map)
  end
  
  def get_body_with_next!(path) do
    response = get!(path)
    next_link = response.headers |> Map.get("Link") |> Map.get("next")
    {response.body, next_link}
  end
end

