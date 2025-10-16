defmodule GitHub.Projects.Project do
  @moduledoc """
  Functions for managing GitHub Projects (v2).

  All functions require a Tesla client created with `GitHub.new/1`.

  ## Required Permissions

  - **List and Get**: "Projects" organization/user permissions (read)

  ## About GitHub Projects

  GitHub Projects (v2) are flexible tools for planning and tracking work.
  This module provides access to project metadata including:
  - Project details (title, description, status)
  - Project ownership information
  - Creation and update timestamps
  - Latest status updates
  """

  @doc """
  Lists all projects for an organization accessible by the authenticated user.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `org`: The organization name (case insensitive)
    - `opts`: Optional query parameters
      - `:q` - Search query to filter projects
      - `:per_page` - Results per page (max 100, default 30)
      - `:before` - Cursor for pagination (before)
      - `:after` - Cursor for pagination (after)

  ## Returns
    - `{:ok, response}` - Success with list of projects
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Project.list_org_projects(client, "my-org")
      {:ok, %{body: [%{"id" => 2, "title" => "My Projects", "number" => 2, ...}]}}

      iex> GitHub.Projects.Project.list_org_projects(client, "my-org", per_page: 50)
      {:ok, %{body: [...]}}
  """
  def list_org_projects(client, org, opts \\ []) do
    query_params = build_query_params(opts)

    client
    |> Tesla.get("/orgs/#{org}/projectsV2", query: query_params)
    |> handle_response()
  end

  @doc """
  Gets a specific organization-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `org`: The organization name (case insensitive)
    - `project_number`: The project's number

  ## Returns
    - `{:ok, response}` - Success with project details
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Project.get_org_project(client, "my-org", 1)
      {:ok, %{body: %{"id" => 2, "title" => "My Projects", "number" => 1, ...}}}
  """
  def get_org_project(client, org, project_number) do
    client
    |> Tesla.get("/orgs/#{org}/projectsV2/#{project_number}")
    |> handle_response()
  end

  @doc """
  Lists all projects for a user accessible by the authenticated user.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `opts`: Optional query parameters
      - `:q` - Search query to filter projects
      - `:per_page` - Results per page (max 100, default 30)
      - `:before` - Cursor for pagination (before)
      - `:after` - Cursor for pagination (after)

  ## Returns
    - `{:ok, response}` - Success with list of projects
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Project.list_user_projects(client, "octocat")
      {:ok, %{body: [%{"id" => 2, "title" => "Personal Projects", ...}]}}

      iex> GitHub.Projects.Project.list_user_projects(client, "octocat", per_page: 50)
      {:ok, %{body: [...]}}
  """
  def list_user_projects(client, username, opts \\ []) do
    query_params = build_query_params(opts)

    client
    |> Tesla.get("/users/#{username}/projectsV2", query: query_params)
    |> handle_response()
  end

  @doc """
  Gets a specific user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number

  ## Returns
    - `{:ok, response}` - Success with project details
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Project.get_user_project(client, "octocat", 1)
      {:ok, %{body: %{"id" => 2, "title" => "Personal Projects", ...}}}
  """
  def get_user_project(client, username, project_number) do
    client
    |> Tesla.get("/users/#{username}/projectsV2/#{project_number}")
    |> handle_response()
  end

  # Private Functions

  defp build_query_params(opts) do
    opts
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> {to_string(k), v} end)
    |> Enum.into(%{})
  end

  defp handle_response({:ok, %Tesla.Env{status: status} = response}) when status in 200..299 do
    {:ok, response}
  end

  defp handle_response({:ok, %Tesla.Env{status: status, body: body}}) do
    {:error, %{status: status, body: body}}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
