defmodule GitHubTest do
  use ExUnit.Case, async: false

  describe "new/1" do
    test "creates client with provided token" do
      client = GitHub.new("ghp_test_token")

      assert %Tesla.Client{} = client
      assert client.pre != []

      # Check that headers middleware is configured
      headers_middleware = Enum.find(client.pre, fn
        {Tesla.Middleware.Headers, :call, _} -> true
        _ -> false
      end)

      assert headers_middleware != nil
    end

    test "creates client with GITHUB_TOKEN env var" do
      System.put_env("GITHUB_TOKEN", "ghp_env_token")

      client = GitHub.new()

      assert %Tesla.Client{} = client

      System.delete_env("GITHUB_TOKEN")
    end

    test "creates client with application config" do
      original = Application.get_env(:github_client, :token)
      Application.put_env(:github_client, :token, "ghp_config_token")

      # Delete env var to ensure config is used
      System.delete_env("GITHUB_TOKEN")

      client = GitHub.new()

      assert %Tesla.Client{} = client

      # Restore original config
      if original do
        Application.put_env(:github_client, :token, original)
      else
        Application.delete_env(:github_client, :token)
      end
    end

    test "raises error when no token is provided" do
      # Clear all token sources
      System.delete_env("GITHUB_TOKEN")
      Application.delete_env(:github_client, :token)

      assert_raise RuntimeError, ~r/GitHub token not found/, fn ->
        GitHub.new()
      end
    end

    test "client includes JSON middleware" do
      client = GitHub.new("ghp_test_token")

      json_middleware = Enum.find(client.pre, fn
        {Tesla.Middleware.JSON, :call, _} -> true
        _ -> false
      end)

      assert json_middleware != nil
    end

    test "client includes BaseUrl middleware" do
      client = GitHub.new("ghp_test_token")

      base_url_middleware = Enum.find(client.pre, fn
        {Tesla.Middleware.BaseUrl, :call, ["https://api.github.com"]} -> true
        _ -> false
      end)

      assert base_url_middleware != nil
    end

    test "client has Hackney adapter configured" do
      client = GitHub.new("ghp_test_token")

      assert client.adapter == {Tesla.Adapter.Hackney, :call, [[recv_timeout: 30_000]]}
    end
  end

  describe "api_version/0" do
    test "returns the API version" do
      assert GitHub.api_version() == "2022-11-28"
    end
  end

  describe "client configuration" do
    test "client includes required headers" do
      client = GitHub.new("ghp_test_token")

      # Find the headers middleware
      {_, _, [headers]} = Enum.find(client.pre, fn
        {Tesla.Middleware.Headers, :call, _} -> true
        _ -> false
      end)

      assert {"accept", "application/vnd.github+json"} in headers
      assert {"authorization", "Bearer ghp_test_token"} in headers
      assert {"x-github-api-version", "2022-11-28"} in headers
    end

    test "token precedence: direct > env > config" do
      # Set both env and config
      System.put_env("GITHUB_TOKEN", "ghp_env_token")
      Application.put_env(:github_client, :token, "ghp_config_token")

      # Direct token should take precedence
      client = GitHub.new("ghp_direct_token")

      {_, _, [headers]} = Enum.find(client.pre, fn
        {Tesla.Middleware.Headers, :call, _} -> true
        _ -> false
      end)

      assert {"authorization", "Bearer ghp_direct_token"} in headers

      # Cleanup
      System.delete_env("GITHUB_TOKEN")
      Application.delete_env(:github_client, :token)
    end

    test "env token takes precedence over config" do
      System.put_env("GITHUB_TOKEN", "ghp_env_token")
      Application.put_env(:github_client, :token, "ghp_config_token")

      client = GitHub.new()

      {_, _, [headers]} = Enum.find(client.pre, fn
        {Tesla.Middleware.Headers, :call, _} -> true
        _ -> false
      end)

      assert {"authorization", "Bearer ghp_env_token"} in headers

      # Cleanup
      System.delete_env("GITHUB_TOKEN")
      Application.delete_env(:github_client, :token)
    end
  end
end
