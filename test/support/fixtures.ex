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

  def project_response do
    %{
      "id" => 2,
      "node_id" => "MDc6UHJvamVjdDEwMDI2MDM=",
      "owner" => %{
        "login" => "octocat",
        "id" => 1,
        "node_id" => "MDQ6VXNlcjE=",
        "type" => "User"
      },
      "creator" => %{
        "login" => "octocat",
        "id" => 1,
        "node_id" => "MDQ6VXNlcjE="
      },
      "title" => "My Projects",
      "description" => "A board to manage my personal projects.",
      "public" => true,
      "closed_at" => nil,
      "created_at" => "2011-04-10T20:09:31Z",
      "updated_at" => "2014-03-03T18:58:10Z",
      "number" => 2,
      "short_description" => nil,
      "deleted_at" => nil,
      "deleted_by" => nil,
      "state" => "open",
      "is_template" => false
    }
  end

  def project_list_response do
    [
      project_response(),
      %{
        "id" => 3,
        "node_id" => "MDc6UHJvamVjdDEwMDI2MDQ=",
        "owner" => %{"login" => "octocat", "id" => 1},
        "creator" => %{"login" => "octocat", "id" => 1},
        "title" => "Another Project",
        "description" => "Second project",
        "public" => true,
        "number" => 3,
        "state" => "open",
        "created_at" => "2012-04-10T20:09:31Z",
        "updated_at" => "2015-03-03T18:58:10Z"
      }
    ]
  end

  def project_field_response do
    %{
      "id" => 12345,
      "node_id" => "PVTF_lADOABCD1234567890",
      "name" => "Priority",
      "data_type" => "single_select",
      "project_url" => "https://api.github.com/projects/67890",
      "options" => [
        %{
          "id" => "option_1",
          "name" => "Low",
          "color" => "GREEN",
          "description" => "Low priority items"
        },
        %{
          "id" => "option_2",
          "name" => "Medium",
          "color" => "YELLOW",
          "description" => "Medium priority items"
        },
        %{
          "id" => "option_3",
          "name" => "High",
          "color" => "RED",
          "description" => "High priority items"
        }
      ],
      "created_at" => "2022-04-28T12:00:00Z",
      "updated_at" => "2022-04-28T12:00:00Z"
    }
  end

  def project_fields_list_response do
    [
      project_field_response(),
      %{
        "id" => 12346,
        "node_id" => "PVTF_lADOABCD1234567891",
        "name" => "Status",
        "data_type" => "single_select",
        "project_url" => "https://api.github.com/projects/67890",
        "options" => [
          %{"id" => "todo", "name" => "Todo"},
          %{"id" => "in_progress", "name" => "In Progress"},
          %{"id" => "done", "name" => "Done"}
        ],
        "created_at" => "2022-04-28T12:00:00Z",
        "updated_at" => "2022-04-28T12:00:00Z"
      }
    ]
  end
end
