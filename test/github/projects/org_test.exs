defmodule GitHub.Projects.OrgTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias GitHub.Projects.{Org, ProjectItem}
  alias GitHub.Test.Fixtures

  setup do
    # Mock adapter is configured globally for test environment
    # Create a test client matching the production setup
    client = Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, "https://api.github.com"},
        Tesla.Middleware.JSON
      ],
      Tesla.Mock
    )
    {:ok, client: client}
  end

  describe "list_items/4" do
    test "successfully lists project items", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/orgs/test-org/projectsV2/1/items"} ->
          json(Fixtures.project_items_list_response(), status: 200)
      end)

      assert {:ok, items} = Org.list_items(client, "test-org", 1)
      assert is_list(items)
      assert length(items) == 2
      assert [%ProjectItem{id: 123}, %ProjectItem{id: 124}] = items
    end

    test "handles query parameters", %{client: client} do
      mock(fn
        %{method: :get, url: url, query: query} ->
          assert url == "https://api.github.com/orgs/test-org/projectsV2/1/items"
          assert query["per_page"] == 50
          assert query["q"] == "status:open"
          json([], status: 200)
      end)

      assert {:ok, []} = Org.list_items(client, "test-org", 1, per_page: 50, q: "status:open")
    end

    test "handles 404 error", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404, body: body}} = Org.list_items(client, "test-org", 1)
      assert body["message"] == "Not Found"
    end

    test "handles network error", %{client: client} do
      mock(fn
        %{method: :get} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = Org.list_items(client, "test-org", 1)
    end
  end

  describe "add_item/4" do
    test "successfully adds an issue to a project", %{client: client} do
      mock(fn
        %{method: :post, url: "https://api.github.com/orgs/test-org/projectsV2/1/items"} ->
          json(Fixtures.project_item_response(), status: 201)
      end)

      assert {:ok, item} = Org.add_item(client, "test-org", 1, %{type: "Issue", id: 123})
      assert %ProjectItem{id: 123} = item
    end

    test "successfully adds a pull request to a project", %{client: client} do
      mock(fn
        %{method: :post} ->
          json(Fixtures.project_item_response(), status: 201)
      end)

      assert {:ok, item} = Org.add_item(client, "test-org", 1, %{type: "PullRequest", id: 456})
      assert %ProjectItem{} = item
    end

    test "rejects invalid item type", %{client: client} do
      assert {:error, message} = Org.add_item(client, "test-org", 1, %{type: "Invalid", id: 123})
      assert message =~ "Invalid item"
    end

    test "rejects missing fields", %{client: client} do
      assert {:error, message} = Org.add_item(client, "test-org", 1, %{type: "Issue"})
      assert message =~ "Invalid item"
    end

    test "handles 403 forbidden error", %{client: client} do
      mock(fn
        %{method: :post} ->
          json(Fixtures.error_response(403, "Forbidden"), status: 403)
      end)

      assert {:error, %{status: 403}} = Org.add_item(client, "test-org", 1, %{type: "Issue", id: 123})
    end
  end

  describe "get_item/4" do
    test "successfully retrieves a project item", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/orgs/test-org/projectsV2/1/items/123"} ->
          json(Fixtures.project_item_response(), status: 200)
      end)

      assert {:ok, item} = Org.get_item(client, "test-org", 1, 123)
      assert %ProjectItem{id: 123, content_type: "Issue"} = item
      assert item.content["title"] == "Example Issue"
    end

    test "handles 404 not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Org.get_item(client, "test-org", 1, 999)
    end
  end

  describe "update_item/5" do
    test "successfully updates a single field", %{client: client} do
      mock(fn
        %{method: :patch, url: url} ->
          assert url == "https://api.github.com/orgs/test-org/projectsV2/1/items/123"
          json(Fixtures.project_item_response(), status: 200)
      end)

      assert {:ok, item} = Org.update_item(client, "test-org", 1, 123, %{
        fields: [%{id: 101, value: "Done"}]
      })
      assert %ProjectItem{} = item
    end

    test "successfully updates multiple fields", %{client: client} do
      mock(fn
        %{method: :patch} ->
          json(Fixtures.project_item_response(), status: 200)
      end)

      assert {:ok, item} = Org.update_item(client, "test-org", 1, 123, %{
        fields: [
          %{id: 101, value: "In Progress"},
          %{id: 102, value: 42},
          %{id: 103, value: nil}
        ]
      })
      assert %ProjectItem{} = item
    end

    test "rejects invalid updates without fields", %{client: client} do
      assert {:error, message} = Org.update_item(client, "test-org", 1, 123, %{invalid: "data"})
      assert message =~ "Invalid updates"
    end

    test "handles validation error", %{client: client} do
      mock(fn
        %{method: :patch} ->
          json(Fixtures.error_response(422, "Validation failed"), status: 422)
      end)

      assert {:error, %{status: 422}} = Org.update_item(client, "test-org", 1, 123, %{
        fields: [%{id: 999, value: "invalid"}]
      })
    end
  end

  describe "delete_item/4" do
    test "successfully deletes a project item", %{client: client} do
      mock(fn
        %{method: :delete, url: "https://api.github.com/orgs/test-org/projectsV2/1/items/123"} ->
          %Tesla.Env{status: 204, body: ""}
      end)

      assert :ok = Org.delete_item(client, "test-org", 1, 123)
    end

    test "handles 401 unauthorized", %{client: client} do
      mock(fn
        %{method: :delete} ->
          json(Fixtures.error_response(401, "Unauthorized"), status: 401)
      end)

      assert {:error, %{status: 401}} = Org.delete_item(client, "test-org", 1, 123)
    end

    test "handles 404 not found", %{client: client} do
      mock(fn
        %{method: :delete} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Org.delete_item(client, "test-org", 1, 999)
    end
  end
end
