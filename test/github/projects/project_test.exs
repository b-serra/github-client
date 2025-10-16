defmodule GitHub.Projects.ProjectTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias GitHub.Projects.Project
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

  describe "list_org_projects/3" do
    test "successfully lists organization projects", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/orgs/test-org/projectsV2"} ->
          json(Fixtures.project_list_response(), status: 200)
      end)

      assert {:ok, response} = Project.list_org_projects(client, "test-org")
      assert response.status == 200
      assert is_list(response.body)
      assert length(response.body) == 2

      [first_project | _] = response.body
      assert first_project["id"] == 2
      assert first_project["title"] == "My Projects"
      assert first_project["number"] == 2
    end

    test "handles query parameters", %{client: client} do
      mock(fn
        %{method: :get, url: url, query: query} ->
          assert url == "https://api.github.com/orgs/test-org/projectsV2"
          assert query["per_page"] == 50
          assert query["q"] == "is:open"
          json([], status: 200)
      end)

      assert {:ok, response} =
               Project.list_org_projects(client, "test-org", per_page: 50, q: "is:open")

      assert response.body == []
    end

    test "handles pagination with after cursor", %{client: client} do
      mock(fn
        %{method: :get, query: query} ->
          assert query["after"] == "cursor123"
          json([], status: 200)
      end)

      assert {:ok, _response} = Project.list_org_projects(client, "test-org", after: "cursor123")
    end

    test "handles 404 error", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404, body: body}} = Project.list_org_projects(client, "test-org")
      assert body["message"] == "Not Found"
    end

    test "handles network error", %{client: client} do
      mock(fn
        %{method: :get} ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = Project.list_org_projects(client, "test-org")
    end
  end

  describe "get_org_project/3" do
    test "successfully retrieves an organization project", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/orgs/test-org/projectsV2/2"} ->
          json(Fixtures.project_response(), status: 200)
      end)

      assert {:ok, response} = Project.get_org_project(client, "test-org", 2)
      assert response.status == 200
      assert response.body["id"] == 2
      assert response.body["title"] == "My Projects"
      assert response.body["description"] == "A board to manage my personal projects."
      assert response.body["state"] == "open"
      assert response.body["number"] == 2
    end

    test "handles 404 not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Project.get_org_project(client, "test-org", 999)
    end

    test "handles 401 unauthorized", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(401, "Requires authentication"), status: 401)
      end)

      assert {:error, %{status: 401}} = Project.get_org_project(client, "test-org", 1)
    end
  end

  describe "list_user_projects/3" do
    test "successfully lists user projects", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/users/octocat/projectsV2"} ->
          json(Fixtures.project_list_response(), status: 200)
      end)

      assert {:ok, response} = Project.list_user_projects(client, "octocat")
      assert response.status == 200
      assert is_list(response.body)
      assert length(response.body) == 2
    end

    test "handles query parameters", %{client: client} do
      mock(fn
        %{method: :get, url: url, query: query} ->
          assert url == "https://api.github.com/users/octocat/projectsV2"
          assert query["per_page"] == 100
          json([], status: 200)
      end)

      assert {:ok, _response} = Project.list_user_projects(client, "octocat", per_page: 100)
    end

    test "handles 404 when user not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Project.list_user_projects(client, "nonexistent")
    end
  end

  describe "get_user_project/3" do
    test "successfully retrieves a user project", %{client: client} do
      mock(fn
        %{method: :get, url: "https://api.github.com/users/octocat/projectsV2/2"} ->
          json(Fixtures.project_response(), status: 200)
      end)

      assert {:ok, response} = Project.get_user_project(client, "octocat", 2)
      assert response.status == 200
      assert response.body["id"] == 2
      assert response.body["title"] == "My Projects"
      assert response.body["owner"]["login"] == "octocat"
    end

    test "handles 404 not found", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(404, "Not Found"), status: 404)
      end)

      assert {:error, %{status: 404}} = Project.get_user_project(client, "octocat", 999)
    end

    test "handles 403 forbidden", %{client: client} do
      mock(fn
        %{method: :get} ->
          json(Fixtures.error_response(403, "Forbidden"), status: 403)
      end)

      assert {:error, %{status: 403}} = Project.get_user_project(client, "octocat", 1)
    end
  end
end
