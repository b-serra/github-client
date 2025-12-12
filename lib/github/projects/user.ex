defmodule GitHub.Projects.User do
  @moduledoc """
  Functions for managing project items in user-owned projects.

  All functions require a Tesla client created with `GitHub.new/1`.

  ## Required Permissions

  - **List and Get**: Projects permissions (read)
  - **Add, Update, Delete**: Projects permissions (write)

  Note: Some endpoints may not work with fine-grained personal access tokens.
  """

  alias GitHub.Projects.ProjectItem

  @doc """
  Lists all items for a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `opts`: Optional query parameters
      - `:q` - Search query to filter items
      - `:fields` - Array of field IDs to include in results
      - `:before` - Cursor for pagination (before)
      - `:after` - Cursor for pagination (after)
      - `:per_page` - Results per page (max 100, default 30)

  ## Returns
    - `{:ok, [%ProjectItem{}]}` - Success with list of project items
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.User.list_items(client, "octocat", 1)
      {:ok, [%GitHub.Projects.ProjectItem{id: 13, ...}]}

      iex> GitHub.Projects.User.list_items(client, "octocat", 1, per_page: 50)
      {:ok, [%GitHub.Projects.ProjectItem{...}, ...]}
  """
  def list_items(client, username, project_number, opts \\ []) do
    query_params = build_query_params(opts)

    client
    |> Tesla.get("/users/#{username}/projectsV2/#{project_number}/items", query: query_params)
    |> handle_response(:list)
  end

  @doc """
  Adds an issue or pull request to a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `item`: Map with item details
      - `type` (required): "Issue" or "PullRequest"
      - `id` (required): The numeric ID of the issue or pull request

  ## Returns
    - `{:ok, %ProjectItem{}}` - Success with created item
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.User.add_item(client, "octocat", 1, %{type: "Issue", id: 123})
      {:ok, %GitHub.Projects.ProjectItem{id: 17, ...}}

      iex> GitHub.Projects.User.add_item(client, "octocat", 1, %{type: "PullRequest", id: 456})
      {:ok, %GitHub.Projects.ProjectItem{...}}
  """
  def add_item(client, username, project_number, %{type: type, id: id})
      when type in ["Issue", "PullRequest"] do
    body = %{
      "type" => type,
      "id" => id
    }

    client
    |> Tesla.post("/users/#{username}/projectsV2/#{project_number}/items", body)
    |> handle_response(:single)
  end

  def add_item(_client, _username, _project_number, item) do
    {:error,
     "Invalid item. Must include 'type' (Issue or PullRequest) and 'id' fields. Got: #{inspect(item)}"}
  end

  @doc """
  Adds a draft issue to a user-owned project.

  Draft issues are items that exist only within the project and are not linked
  to a repository. They can later be converted to regular issues if needed.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `item`: Map with draft issue details
      - `title` (required): The title of the draft issue
      - `body` (optional): The body/description of the draft issue

  ## Returns
    - `{:ok, %ProjectItem{}}` - Success with created draft item
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.User.add_draft_item(client, "octocat", 1, %{title: "New feature"})
      {:ok, %GitHub.Projects.ProjectItem{id: 17, content_type: "DraftIssue", ...}}

      iex> GitHub.Projects.User.add_draft_item(client, "octocat", 1, %{title: "Bug fix", body: "Fix the login issue"})
      {:ok, %GitHub.Projects.ProjectItem{...}}
  """
  def add_draft_item(client, username, project_number, %{title: title} = item) do
    body =
      %{
        "type" => "DraftIssue",
        "title" => title
      }
      |> maybe_add_body(item)

    client
    |> Tesla.post("/users/#{username}/projectsV2/#{project_number}/items", body)
    |> handle_response(:single)
  end

  def add_draft_item(_client, _username, _project_number, item) do
    {:error, "Invalid draft item. Must include 'title' field. Got: #{inspect(item)}"}
  end

  defp maybe_add_body(body, %{body: item_body}) when is_binary(item_body) and item_body != "" do
    Map.put(body, "body", item_body)
  end

  defp maybe_add_body(body, _item), do: body

  @doc """
  Gets a specific item from a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `item_id`: The unique identifier of the project item

  ## Returns
    - `{:ok, %ProjectItem{}}` - Success with item details
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.User.get_item(client, "octocat", 1, 456)
      {:ok, %GitHub.Projects.ProjectItem{id: 456, ...}}
  """
  def get_item(client, username, project_number, item_id) do
    client
    |> Tesla.get("/users/#{username}/projectsV2/#{project_number}/items/#{item_id}")
    |> handle_response(:single)
  end

  @doc """
  Updates a specific item in a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `item_id`: The unique identifier of the project item
    - `updates`: Map with fields to update
      - `fields` (required): Array of field updates, each with:
        - `id` (required): The ID of the project field
        - `value` (required): New value (string, number, or null to clear)

  ## Returns
    - `{:ok, %ProjectItem{}}` - Success with updated item
    - `{:error, reason}` - Error response

  ## Examples

      # Update a text field
      iex> GitHub.Projects.User.update_item(client, "octocat", 1, 456, %{
      ...>   fields: [%{id: 123, value: "Updated text"}]
      ...> })
      {:ok, %GitHub.Projects.ProjectItem{id: 456, ...}}

      # Update multiple fields
      iex> GitHub.Projects.User.update_item(client, "octocat", 1, 456, %{
      ...>   fields: [
      ...>     %{id: 123, value: "In Progress"},
      ...>     %{id: 124, value: 42}
      ...>   ]
      ...> })
      {:ok, %GitHub.Projects.ProjectItem{...}}

      # Clear a field
      iex> GitHub.Projects.User.update_item(client, "octocat", 1, 456, %{
      ...>   fields: [%{id: 123, value: nil}]
      ...> })
      {:ok, %GitHub.Projects.ProjectItem{...}}
  """
  def update_item(client, username, project_number, item_id, %{fields: fields})
      when is_list(fields) do
    body = %{"fields" => fields}

    client
    |> Tesla.patch("/users/#{username}/projectsV2/#{project_number}/items/#{item_id}", body)
    |> handle_response(:single)
  end

  def update_item(_client, _username, _project_number, _item_id, updates) do
    {:error, "Invalid updates. Must include 'fields' array. Got: #{inspect(updates)}"}
  end

  @doc """
  Deletes a specific item from a user-owned project.

  ## Parameters
    - `client`: Tesla client from `GitHub.new/1`
    - `username`: The GitHub username
    - `project_number`: The project's number
    - `item_id`: The unique identifier of the project item

  ## Returns
    - `:ok` - Success (item deleted)
    - `{:error, reason}` - Error response

  ## Examples

      iex> GitHub.Projects.User.delete_item(client, "octocat", 1, 456)
      :ok
  """
  def delete_item(client, username, project_number, item_id) do
    client
    |> Tesla.delete("/users/#{username}/projectsV2/#{project_number}/items/#{item_id}")
    |> handle_response(:delete)
  end

  # Private Functions

  defp build_query_params(opts) do
    opts
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> {to_string(k), v} end)
    |> Enum.into(%{})
  end

  defp handle_response({:ok, %Tesla.Env{status: status, body: body}}, :list)
       when status in 200..299 do
    items = if is_list(body), do: body, else: [body]
    {:ok, ProjectItem.new_list(items)}
  end

  defp handle_response({:ok, %Tesla.Env{status: status, body: body}}, :single)
       when status in 200..299 do
    {:ok, ProjectItem.new(body)}
  end

  defp handle_response({:ok, %Tesla.Env{status: 204}}, :delete) do
    :ok
  end

  defp handle_response({:ok, %Tesla.Env{status: status, body: body}}, _mode) do
    {:error, %{status: status, body: body}}
  end

  defp handle_response({:error, reason}, _mode) do
    {:error, reason}
  end
end
