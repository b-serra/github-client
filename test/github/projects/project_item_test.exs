defmodule GitHub.Projects.ProjectItemTest do
  use ExUnit.Case, async: true

  alias GitHub.Projects.ProjectItem
  alias GitHub.Test.Fixtures

  describe "new/1" do
    test "creates a ProjectItem struct from API response data" do
      data = Fixtures.project_item_response()
      item = ProjectItem.new(data)

      assert %ProjectItem{} = item
      assert item.id == 123
      assert item.node_id == "PVTI_lADOANN5s84ACbL0zgBueEI"
      assert item.project_url == "https://api.github.com/orgs/github/projectsV2/1"
      assert item.content_type == "Issue"
      assert item.content["title"] == "Example Issue"
      assert item.creator["login"] == "octocat"
      assert item.created_at == "2025-01-01T10:00:00Z"
      assert item.updated_at == "2025-01-02T10:00:00Z"
      assert item.archived_at == nil
      assert item.item_url == "https://api.github.com/orgs/github/projectsV2/1/items/123"
      assert length(item.fields) == 2
    end

    test "handles missing optional fields" do
      data = %{
        "id" => 999,
        "node_id" => "PVTI_test"
      }

      item = ProjectItem.new(data)

      assert %ProjectItem{} = item
      assert item.id == 999
      assert item.node_id == "PVTI_test"
      assert item.project_url == nil
      assert item.content == nil
      assert item.fields == nil
    end

    test "handles empty map" do
      item = ProjectItem.new(%{})

      assert %ProjectItem{} = item
      assert item.id == nil
      assert item.node_id == nil
    end
  end

  describe "new_list/1" do
    test "creates a list of ProjectItem structs" do
      data = Fixtures.project_items_list_response()
      items = ProjectItem.new_list(data)

      assert is_list(items)
      assert length(items) == 2
      assert Enum.all?(items, &match?(%ProjectItem{}, &1))

      [first, second] = items
      assert first.id == 123
      assert second.id == 124
    end

    test "handles empty list" do
      items = ProjectItem.new_list([])

      assert items == []
    end

    test "handles list with single item" do
      data = [Fixtures.project_item_response()]
      items = ProjectItem.new_list(data)

      assert length(items) == 1
      assert [%ProjectItem{id: 123}] = items
    end
  end

  describe "struct fields" do
    test "all expected fields are accessible" do
      item = %ProjectItem{
        id: 1,
        node_id: "node_1",
        project_url: "url",
        content: %{"title" => "test"},
        content_type: "Issue",
        creator: %{"login" => "user"},
        created_at: "2025-01-01T00:00:00Z",
        updated_at: "2025-01-02T00:00:00Z",
        archived_at: nil,
        item_url: "item_url",
        fields: []
      }

      assert item.id == 1
      assert item.node_id == "node_1"
      assert item.project_url == "url"
      assert item.content == %{"title" => "test"}
      assert item.content_type == "Issue"
      assert item.creator == %{"login" => "user"}
      assert item.created_at == "2025-01-01T00:00:00Z"
      assert item.updated_at == "2025-01-02T00:00:00Z"
      assert item.archived_at == nil
      assert item.item_url == "item_url"
      assert item.fields == []
    end
  end
end
