defmodule GitHub.Projects.UserTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias GitHub.Projects.{User, ProjectItem}
  alias GitHub.Test.Fixtures

  setup do
    # Mock adapter is configured globally for test environment
    # Create a test client matching the production setup
    client =
      Tesla.client(
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
        %{method: :get, url: "https://api.github.com/users/octocat/projectsV2/1/items"} ->
          json(Fixtures.project_items_list_response(), status: 200)
      end)

      assert {:ok, items} = User.list_items(client, "octocat", 1)
      assert is_list(items)
      assert length(items) == 2
      assert [%ProjectItem{id: 123}, %ProjectItem{id: 124}] = items
    end

    test "handles query parameters", %{client: client} do
      mock(fn
        %{method: :get, url: url, query: query} ->
          assert url == "https://api.github.com/users/octocat/projectsV2/1/items"
          assert query["per_page"] == 100
          assert query["after"] == "cursor123"
          json([], status: 200)
      end)

      assert {:ok, []} = User.list_items(client, "octocat", 1, per_page: 100, after: "cursor123")
    end

    test "handles empty result", %{client: client} do
      mock(fn
        %{method: :get} ->
          json([], status: 200)
      end)

      assert {:ok, []} = User.list_items(client, "octocat", 1)
    end

    test "handles 403 forbidden", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(403, "Forbidden"), status: 403)
      end)

      assert {:error, %{status: 403}} = User.list_items(client, "octocat", 1)
    end
  end

  describe "add_item/4" do
    test "successfully adds an issue", %{client: client} do
      mock(fn
        %{method: :post, url: "https://api.github.com/users/octocat/projectsV2/1/items"} ->
          json(Fixtures.project_item_response(), status: 201)
      end)

      assert {:ok, item} = User.add_item(client, "octocat", 1, %{type: "Issue", id: 789})
      assert %ProjectItem{id: 123} = item
    end

    test "successfully adds a pull request", %{client: client} do
      mock(fn
        %{method: :post} ->
          json(Fixtures.project_item_response(), status: 201)
      end)

      assert {:ok, item} = User.add_item(client, "octocat", 1, %{type: "PullRequest", id: 100})
      assert %ProjectItem{} = item
    end

    test "rejects invalid item", %{client: client} do
      assert {:error, message} = User.add_item(client, "octocat", 1, %{})
      assert message =~ "Invalid item"
    end

    test "handles rate limit error", %{client: client} do
      mock(fn
        %{method: :post} ->
          json(%{"message" => "API rate limit exceeded"}, status: 429)
      end)

      assert {:error, %{status: 429}} =
               User.add_item(client, "octocat", 1, %{type: "Issue", id: 1})
    end
  end

  describe "get_item/4" do
    test "successfully retrieves an item", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/users/octocat/projectsV2/1/items/456"} ->
          json(Fixtures.project_item_response(), status: 200)
      end)

      assert {:ok, item} = User.get_item(client, "octocat", 1, 456)
      assert %ProjectItem{id: 123} = item
      assert item.content_type == "Issue"
    end

    test "handles not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = User.get_item(client, "octocat", 1, 999)
    end
  end

  describe "update_item/5" do
    test "successfully updates field", %{client: client} do
      mock(fn
        %{method: :patch, url: url} ->
          assert url == "https://api.github.com/users/octocat/projectsV2/1/items/456"
          json(Fixtures.project_item_response(), status: 200)
      end)

      assert {:ok, item} =
               User.update_item(client, "octocat", 1, 456, %{
                 fields: [%{id: 1, value: "Complete"}]
               })

      assert %ProjectItem{} = item
    end

    test "clears field with nil value", %{client: client} do
      mock(fn
        %{method: :patch} ->
          json(Fixtures.project_item_response(), status: 200)
      end)

      assert {:ok, item} =
               User.update_item(client, "octocat", 1, 456, %{
                 fields: [%{id: 5, value: nil}]
               })

      assert %ProjectItem{} = item
    end

    test "rejects updates without fields array", %{client: client} do
      assert {:error, message} = User.update_item(client, "octocat", 1, 456, %{status: "done"})
      assert message =~ "Invalid updates"
    end

    test "handles not found error", %{client: client} do
      mock(fn
        %{method: :patch} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} =
               User.update_item(client, "octocat", 1, 999, %{
                 fields: [%{id: 1, value: "test"}]
               })
    end
  end

  describe "delete_item/4" do
    test "successfully deletes item", %{client: client} do
      mock(fn
        %{method: :delete, url: "https://api.github.com/users/octocat/projectsV2/1/items/456"} ->
          %Tesla.Env{status: 204, body: ""}
      end)

      assert :ok = User.delete_item(client, "octocat", 1, 456)
    end

    test "handles unauthorized", %{client: client} do
      mock(fn
        %{method: :delete} ->
          json(Fixtures.error_response(401, "Requires authentication"), status: 401)
      end)

      assert {:error, %{status: 401}} = User.delete_item(client, "octocat", 1, 456)
    end

    test "handles not found", %{client: client} do
      mock(fn
        %{method: :delete} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = User.delete_item(client, "octocat", 1, 999)
    end
  end
end
