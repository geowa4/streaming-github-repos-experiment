defmodule GitHubRepoTest do
  use ExUnit.Case
  import Mock
  doctest GitHub.Repo

  test "stream repos" do
    # mock get_repos!
  endpoint = "https://api.github.com"
    get = fn path ->
      if path === ~s(#{endpoint}/orgs/foo/repos/per_page=1&page=2) do
        {
          ~s([{"id":124,"name":"foo","full_name":"foo/bar","html_url":"/baz","description":"quux"}]),
          nil
        }
      else
        {
          ~s([{"id":123,"name":"foo","full_name":"foo/bar","html_url":"/baz","description":"quux"}]),
          ~s(#{endpoint}/orgs/foo/repos/per_page=1&page=2)
        }
      end
    end

    with_mock GitHub, [get_body_with_next!: get] do
      repos = GitHub.Repo.stream_repos("elixir-lang", 1) |> Enum.to_list
      assert Enum.count(repos) === 2
    end
  end
end
