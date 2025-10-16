defmodule GitHub.Test.Fixtures do
  @moduledoc """
  Test fixtures for GitHub API responses.
  """

  def project_item_response do
    %{
      "id" => 123,
      "node_id" => "PVTI_lADOANN5s84ACbL0zgBueEI",
      "project_url" => "https://api.github.com/orgs/github/projectsV2/1",
      "content" => %{
        "id" => 456,
        "node_id" => "I_kwDOANN5s85FtLts",
        "number" => 42,
        "title" => "Example Issue",
        "body" => "This is a test issue",
        "state" => "open",
        "created_at" => "2025-01-01T10:00:00Z",
        "updated_at" => "2025-01-02T10:00:00Z"
      },
      "content_type" => "Issue",
      "creator" => %{
        "login" => "octocat",
        "id" => 1,
        "type" => "User"
      },
      "created_at" => "2025-01-01T10:00:00Z",
      "updated_at" => "2025-01-02T10:00:00Z",
      "archived_at" => nil,
      "item_url" => "https://api.github.com/orgs/github/projectsV2/1/items/123",
      "fields" => [
        %{"id" => 1, "name" => "Status", "value" => "In Progress"},
        %{"id" => 2, "name" => "Priority", "value" => "High"}
      ]
    }
  end

  def project_items_list_response do
    [
      project_item_response(),
      %{
        "id" => 124,
        "node_id" => "PVTI_lADOANN5s84ACbL0zgBueEJ",
        "project_url" => "https://api.github.com/orgs/github/projectsV2/1",
        "content" => %{
          "id" => 457,
          "number" => 43,
          "title" => "Another Issue"
        },
        "content_type" => "Issue",
        "creator" => %{"login" => "octocat", "id" => 1},
        "created_at" => "2025-01-03T10:00:00Z",
        "updated_at" => "2025-01-03T10:00:00Z",
        "archived_at" => nil,
        "item_url" => "https://api.github.com/orgs/github/projectsV2/1/items/124"
      }
    ]
  end

  def error_response(_status, message) do
    %{
      "message" => message,
      "documentation_url" => "https://docs.github.com/rest"
    }
  end
end
