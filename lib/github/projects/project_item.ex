defmodule GitHub.Projects.ProjectItem do
  @moduledoc """
  Represents a project item in a GitHub Project.

  A project item can be an issue, pull request, or draft issue associated with a project.
  """

  @type t :: %__MODULE__{
          id: integer(),
          node_id: String.t() | nil,
          project_url: String.t() | nil,
          content: map() | nil,
          content_type: String.t() | nil,
          creator: map() | nil,
          created_at: String.t() | nil,
          updated_at: String.t() | nil,
          archived_at: String.t() | nil,
          item_url: String.t() | nil,
          fields: list(map()) | nil
        }

  defstruct [
    :id,
    :node_id,
    :project_url,
    :content,
    :content_type,
    :creator,
    :created_at,
    :updated_at,
    :archived_at,
    :item_url,
    :fields
  ]

  @doc """
  Creates a ProjectItem struct from API response data.

  ## Parameters
    - `data`: Map containing project item data from GitHub API

  ## Returns
    `%GitHub.Projects.ProjectItem{}`

  ## Examples

      iex> GitHub.Projects.ProjectItem.new(%{"id" => 123, "node_id" => "PVTI_..."})
      %GitHub.Projects.ProjectItem{id: 123, node_id: "PVTI_..."}
  """
  @spec new(map()) :: t()
  def new(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      node_id: data["node_id"],
      project_url: data["project_url"],
      content: data["content"],
      content_type: data["content_type"],
      creator: data["creator"],
      created_at: data["created_at"],
      updated_at: data["updated_at"],
      archived_at: data["archived_at"],
      item_url: data["item_url"],
      fields: data["fields"]
    }
  end

  @doc """
  Creates a list of ProjectItem structs from API response data.

  ## Parameters
    - `items`: List of maps containing project item data

  ## Returns
    List of `%GitHub.Projects.ProjectItem{}`

  ## Examples

      iex> GitHub.Projects.ProjectItem.new_list([%{"id" => 1}, %{"id" => 2}])
      [%GitHub.Projects.ProjectItem{id: 1}, %GitHub.Projects.ProjectItem{id: 2}]
  """
  @spec new_list(list(map())) :: list(t())
  def new_list(items) when is_list(items) do
    Enum.map(items, &new/1)
  end
end
