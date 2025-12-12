defmodule GitHub do
  @moduledoc """
  A comprehensive Elixir client for the GitHub REST API.

  This module provides a simple, idiomatic interface to interact with GitHub's API,
  supporting various endpoints across the GitHub platform.

  ## Configuration

  The client requires a GitHub token for authentication. You can configure it in several ways:

  ### Option 1: Pass token directly
      client = GitHub.new("ghp_your_token_here")

  ### Option 2: Use environment variable
      # Set GITHUB_TOKEN in your environment
      client = GitHub.new()

  ### Option 3: Use application config
      # In config/config.exs
      config :github_client, token: "ghp_your_token_here"

      # In your code
      client = GitHub.new()

  ## API Version

  All endpoints use GitHub API version `2022-11-28`.

  ## Usage Examples

      # Create a client
      client = GitHub.new("ghp_your_token")

      # Projects API - List all organization projects
      {:ok, response} = GitHub.Projects.Project.list_org_projects(client, "my-org")

      # Projects API - Get a specific project
      {:ok, response} = GitHub.Projects.Project.get_org_project(client, "my-org", 1)

      # Projects API - List project fields
      {:ok, response} = GitHub.Projects.Fields.list_org_fields(client, "my-org", 1)

      # Projects API - List items in an organization project
      {:ok, items} = GitHub.Projects.Org.list_items(client, "my-org", 1)
      # items is a list of %GitHub.Projects.ProjectItem{} structs

      # Projects API - Add an issue to a project
      {:ok, item} = GitHub.Projects.Org.add_item(client, "my-org", 1, %{
        type: "Issue",
        id: 123
      })
      # item is a %GitHub.Projects.ProjectItem{} struct

      # Projects API - Update a project item
      {:ok, updated_item} = GitHub.Projects.Org.update_item(client, "my-org", 1, 456, %{
        fields: [%{id: 789, value: "In Progress"}]
      })
      # updated_item is a %GitHub.Projects.ProjectItem{} struct

      # Projects API - Add a draft issue to a project (not linked to any repository)
      {:ok, draft} = GitHub.Projects.Org.add_draft_item(client, "my-org", 1, %{
        title: "New task",
        body: "Description of the task"
      })
      # draft is a %GitHub.Projects.ProjectItem{} struct with content_type: "DraftIssue"

  ## Available API Modules

  ### Projects (v2)
  - `GitHub.Projects.Project` - List and retrieve projects for organizations and users
  - `GitHub.Projects.Fields` - Manage project fields (custom properties)
  - `GitHub.Projects.Org` - Organization-owned project items (CRUD operations)
  - `GitHub.Projects.User` - User-owned project items (CRUD operations)
  """

  use Tesla

  @api_version "2022-11-28"
  @base_url "https://api.github.com"

  @doc """
  Creates a new GitHub API client.

  ## Parameters
    - `token` (optional): GitHub personal access token. If not provided, will look for:
      1. `GITHUB_TOKEN` environment variable
      2. Application config under `:github_client, :token`

  ## Returns
    A Tesla client configured for GitHub API requests.

  ## Examples

      iex> client = GitHub.new("ghp_token")
      iex> client = GitHub.new()
  """
  def new(token \\ nil) do
    auth_token = token || get_token()

    middleware = [
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers,
       [
         {"accept", "application/vnd.github+json"},
         {"authorization", "Bearer #{auth_token}"},
         {"x-github-api-version", @api_version}
       ]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware, {Tesla.Adapter.Hackney, [recv_timeout: 30_000]})
  end

  @doc """
  Returns the API version used by this client.
  """
  def api_version, do: @api_version

  # Private Functions

  defp get_token do
    System.get_env("GITHUB_TOKEN") ||
      Application.get_env(:github_client, :token) ||
      raise """
      GitHub token not found!

      Please provide a token in one of the following ways:
      1. Pass it directly: GitHub.new("ghp_your_token")
      2. Set GITHUB_TOKEN environment variable
      3. Configure in config.exs: config :github_client, token: "ghp_your_token"
      """
  end
end
