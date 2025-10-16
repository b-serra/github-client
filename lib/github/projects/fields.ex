defmodule GitHub.Projects.Fields do
  @moduledoc """
  Functions for managing project fields.

  All functions require a Tesla client created with `GitHub.new/1`.

  ## Required Permissions

  - **List and Get**: "Projects" organization/user permissions (read)

  ## About Project Fields

  Project fields define the custom properties for items in a project, such as:
  - Single select fields (e.g., Status, Priority)
  - Text fields
  - Number fields
  - Date fields
  - Iteration fields
  """

  @doc """
  Lists all fields for an organization-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `org`: The organization name (case insensitive)
    - `project_number`: The project's number
    - `opts`: Optional query parameters
      - `:per_page` - Results per page (max 100, default 30)
      - `:before` - Cursor for pagination (before)
      - `:after` - Cursor for pagination (after)

  ## Returns
    - `{:ok, response}` - Success with list of project fields
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Fields.list_org_fields(client, "my-org", 1)
      {:ok, %{body: [%{"id" => 12345, "name" => "Priority", "data_type" => "single_select", ...}]}}

      iex> GitHub.Projects.Fields.list_org_fields(client, "my-org", 1, per_page: 50)
      {:ok, %{body: [...]}}
  """
  def list_org_fields(client, org, project_number, opts \\ []) do
    query_params = build_query_params(opts)

    client
    |> Tesla.get("/orgs/#{org}/projectsV2/#{project_number}/fields", query: query_params)
    |> handle_response()
  end

  @doc """
  Gets a specific field from an organization-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `org`: The organization name (case insensitive)
    - `project_number`: The project's number
    - `field_id`: The unique identifier of the field

  ## Returns
    - `{:ok, response}` - Success with field details
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Fields.get_org_field(client, "my-org", 1, 12345)
      {:ok, %{body: %{"id" => 12345, "name" => "Priority", "data_type" => "single_select", ...}}}
  """
  def get_org_field(client, org, project_number, field_id) do
    client
    |> Tesla.get("/orgs/#{org}/projectsV2/#{project_number}/fields/#{field_id}")
    |> handle_response()
  end

  @doc """
  Lists all fields for a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `opts`: Optional query parameters
      - `:per_page` - Results per page (max 100, default 30)
      - `:before` - Cursor for pagination (before)
      - `:after` - Cursor for pagination (after)

  ## Returns
    - `{:ok, response}` - Success with list of project fields
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Fields.list_user_fields(client, "octocat", 1)
      {:ok, %{body: [%{"id" => 12345, "name" => "Status", ...}]}}

      iex> GitHub.Projects.Fields.list_user_fields(client, "octocat", 1, per_page: 50)
      {:ok, %{body: [...]}}
  """
  def list_user_fields(client, username, project_number, opts \\ []) do
    query_params = build_query_params(opts)

    client
    |> Tesla.get("/users/#{username}/projectsV2/#{project_number}/fields", query: query_params)
    |> handle_response()
  end

  @doc """
  Gets a specific field from a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `field_id`: The unique identifier of the field

  ## Returns
    - `{:ok, response}` - Success with field details
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.Fields.get_user_field(client, "octocat", 1, 12345)
      {:ok, %{body: %{"id" => 12345, "name" => "Status", ...}}}
  """
  def get_user_field(client, username, project_number, field_id) do
    client
    |> Tesla.get("/users/#{username}/projectsV2/#{project_number}/fields/#{field_id}")
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
