defmodule GitHub.Repo do
  @moduledoc """
  GitHub Repos
  """

  defmodule RepoData do
    @moduledoc """
    Struct for the data representing a GitHub repo.
    """
    @derive [Poison.Encoder]
    defstruct [
      :id, :name, :full_name, :html_url, :description
    ]
  end

  defp get_repos!(path) do
    {body, next_link} = GitHub.get_body_with_next!(path)
    {Poison.decode!(body, as: [%RepoData{}]), next_link}
  end

  defp process_next({nil, nil}), do: {:halt, nil}
  defp process_next({nil, next_link}) do
    next_link
    |> get_repos!
    |> process_next
  end
  defp process_next({repos, next_link}), do: {repos, {nil, next_link}}

  def stream_repos(org \\ "elixir-lang", per_page \\ 100) do
    Stream.resource(
      fn ->
        get_repos!("/orgs/#{org}/repos?per_page=#{per_page}")
      end,
      &process_next/1,
      fn _ -> nil end
    )
  end
end

