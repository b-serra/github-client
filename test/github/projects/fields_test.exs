defmodule GitHub.Projects.FieldsTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias GitHub.Projects.Fields
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

  describe "list_org_fields/4" do
    test "successfully lists organization project fields", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/orgs/test-org/projectsV2/1/fields"} ->
          json(Fixtures.project_fields_list_response(), status: 200)
      end)

      assert {:ok, response} = Fields.list_org_fields(client, "test-org", 1)
      assert response.status == 200
      assert is_list(response.body)
      assert length(response.body) == 2

      [first_field | _] = response.body
      assert first_field["id"] == 12345
      assert first_field["name"] == "Priority"
      assert first_field["data_type"] == "single_select"
      assert length(first_field["options"]) == 3
    end

    test "handles query parameters", %{client: client} do
      mock(fn
        %{method: :get, url: url, query: query} ->
          assert url == "https://api.github.com/orgs/test-org/projectsV2/1/fields"
          assert query["per_page"] == 50
          json([], status: 200)
      end)

      assert {:ok, response} = Fields.list_org_fields(client, "test-org", 1, per_page: 50)
      assert response.body == []
    end

    test "handles pagination with cursors", %{client: client} do
      mock(fn
        %{method: :get, query: query} ->
          assert query["after"] == "cursor123"
          assert query["before"] == nil
          json([], status: 200)
      end)

      assert {:ok, _response} = Fields.list_org_fields(client, "test-org", 1, after: "cursor123")
    end

    test "handles 404 error when project not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404, body: body}} =
               Fields.list_org_fields(client, "test-org", 999)

      assert body["message"] == "Not Found"
    end

    test "handles 401 unauthorized", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(401, "Requires authentication"), status: 401)
      end)

      assert {:error, %{status: 401}} = Fields.list_org_fields(client, "test-org", 1)
    end

    test "handles network error", %{client: client} do
      mock(fn
        %{method: :get} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = Fields.list_org_fields(client, "test-org", 1)
    end
  end

  describe "get_org_field/4" do
    test "successfully retrieves an organization project field", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/orgs/test-org/projectsV2/1/fields/12345"} ->
          json(Fixtures.project_field_response(), status: 200)
      end)

      assert {:ok, response} = Fields.get_org_field(client, "test-org", 1, 12345)
      assert response.status == 200
      assert response.body["id"] == 12345
      assert response.body["name"] == "Priority"
      assert response.body["data_type"] == "single_select"

      options = response.body["options"]
      assert length(options) == 3
      assert Enum.any?(options, &(&1["name"] == "Low"))
      assert Enum.any?(options, &(&1["name"] == "Medium"))
      assert Enum.any?(options, &(&1["name"] == "High"))
    end

    test "handles 404 when field not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Fields.get_org_field(client, "test-org", 1, 99999)
    end

    test "handles 403 forbidden", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(403, "Forbidden"), status: 403)
      end)

      assert {:error, %{status: 403}} = Fields.get_org_field(client, "test-org", 1, 12345)
    end
  end

  describe "list_user_fields/4" do
    test "successfully lists user project fields", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/users/octocat/projectsV2/1/fields"} ->
          json(Fixtures.project_fields_list_response(), status: 200)
      end)

      assert {:ok, response} = Fields.list_user_fields(client, "octocat", 1)
      assert response.status == 200
      assert is_list(response.body)
      assert length(response.body) == 2

      [first_field, second_field] = response.body
      assert first_field["name"] == "Priority"
      assert second_field["name"] == "Status"
    end

    test "handles query parameters", %{client: client} do
      mock(fn
        %{method: :get, url: url, query: query} ->
          assert url == "https://api.github.com/users/octocat/projectsV2/1/fields"
          assert query["per_page"] == 100
          json([], status: 200)
      end)

      assert {:ok, _response} = Fields.list_user_fields(client, "octocat", 1, per_page: 100)
    end

    test "handles empty field list", %{client: client} do
      mock(fn
        %{method: :get} ->
          json([], status: 200)
      end)

      assert {:ok, response} = Fields.list_user_fields(client, "octocat", 1)
      assert response.body == []
    end

    test "handles 404 when user or project not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Fields.list_user_fields(client, "nonexistent", 1)
    end
  end

  describe "get_user_field/4" do
    test "successfully retrieves a user project field", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/users/octocat/projectsV2/1/fields/12345"} ->
          json(Fixtures.project_field_response(), status: 200)
      end)

      assert {:ok, response} = Fields.get_user_field(client, "octocat", 1, 12345)
      assert response.status == 200
      assert response.body["id"] == 12345
      assert response.body["name"] == "Priority"
      assert response.body["project_url"] == "https://api.github.com/projects/67890"
    end

    test "verifies field options structure", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.project_field_response(), status: 200)
      end)

      assert {:ok, response} = Fields.get_user_field(client, "octocat", 1, 12345)

      options = response.body["options"]
      assert is_list(options)

      [low_option | _] = options
      assert low_option["id"] == "option_1"
      assert low_option["name"] == "Low"
      assert low_option["color"] == "GREEN"
      assert low_option["description"] == "Low priority items"
    end

    test "handles 404 when field not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Fields.get_user_field(client, "octocat", 1, 99999)
    end

    test "handles 403 forbidden", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(403, "Forbidden"), status: 403)
      end)

      assert {:error, %{status: 403}} = Fields.get_user_field(client, "octocat", 1, 12345)
    end

    test "handles network timeout", %{client: client} do
      mock(fn
        %{method: :get} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = Fields.get_user_field(client, "octocat", 1, 12345)
    end
  end
end
