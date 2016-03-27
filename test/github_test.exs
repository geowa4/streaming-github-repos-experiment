defmodule GitHubTest do
  use ExUnit.Case
  doctest GitHub
  
  test "link parsing" do
    link_header = ~s(<https://api.github.com/organizations/1481354/repos?per_page=1&page=2>; rel="next",
    <https://api.github.com/organizations/1481354/repos?per_page=1&page=13>; rel="last">)
    headers = [{"Link", link_header}]
    expected = %{"Link" => %{
      "next" =>
        "https://api.github.com/organizations/1481354/repos?per_page=1&page=2",
      "last" =>
        "https://api.github.com/organizations/1481354/repos?per_page=1&page=13"
    }}
    assert GitHub.process_headers(headers) === expected
  end

  test "no link header" do
    headers = [{"X-RateLimit-Remaining", 59}]
    expected = %{"Link" => %{}, "X-RateLimit-Remaining" => 59}
    assert GitHub.process_headers(headers) === expected
  end
end
