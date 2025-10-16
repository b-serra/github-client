# GitHub Client

A comprehensive Elixir client for the GitHub REST API using Tesla as the HTTP client.

## Features

- Simple, idiomatic Elixir API
- Comprehensive GitHub API coverage
- Built on Tesla for flexible HTTP handling
- Built-in authentication and error handling
- Full documentation and examples

## Installation

Add `github_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:github_client, "~> 0.1.0"}
  ]
end
```

## Configuration

You need a GitHub personal access token with appropriate permissions to use this library.

### Option 1: Environment Variable

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

Then in your code:

```elixir
client = GitHub.new()
```

### Option 2: Application Config

In `config/config.exs`:

```elixir
config :github_client, token: "ghp_your_token_here"
```

Then in your code:

```elixir
client = GitHub.new()
```

### Option 3: Pass Token Directly

```elixir
client = GitHub.new("ghp_your_token_here")
```

## API Modules

### Projects API

Functions for managing GitHub Projects v2.

#### Projects (List and Retrieve)

```elixir
# Create a client
client = GitHub.new("ghp_your_token")

# List all organization projects
{:ok, response} = GitHub.Projects.Project.list_org_projects(client, "my-org")

# List with pagination
{:ok, response} = GitHub.Projects.Project.list_org_projects(client, "my-org", per_page: 50)

# Get a specific organization project
{:ok, response} = GitHub.Projects.Project.get_org_project(client, "my-org", 1)

# List all user projects
{:ok, response} = GitHub.Projects.Project.list_user_projects(client, "octocat")

# Get a specific user project
{:ok, response} = GitHub.Projects.Project.get_user_project(client, "octocat", 1)
```

#### Project Fields

```elixir
# List all fields for an organization project
{:ok, response} = GitHub.Projects.Fields.list_org_fields(client, "my-org", 1)

# Get a specific field
{:ok, response} = GitHub.Projects.Fields.get_org_field(client, "my-org", 1, 12345)

# List all fields for a user project
{:ok, response} = GitHub.Projects.Fields.list_user_fields(client, "octocat", 1)

# Get a specific field
{:ok, response} = GitHub.Projects.Fields.get_user_field(client, "octocat", 1, 12345)
```

#### Project Items (Organization-Owned)

```elixir
# Create a client
client = GitHub.new("ghp_your_token")

# List all items in a project
{:ok, items} = GitHub.Projects.Org.list_items(client, "my-org", 1)
# items is a list of %GitHub.Projects.ProjectItem{} structs

# List with pagination and filtering
{:ok, items} = GitHub.Projects.Org.list_items(client, "my-org", 1,
  per_page: 50,
  q: "status:open"
)

# Add an issue to a project
{:ok, item} = GitHub.Projects.Org.add_item(client, "my-org", 1, %{
  type: "Issue",
  id: 123
})

# Add a pull request to a project
{:ok, item} = GitHub.Projects.Org.add_item(client, "my-org", 1, %{
  type: "PullRequest",
  id: 456
})

# Get a specific item
{:ok, item} = GitHub.Projects.Org.get_item(client, "my-org", 1, 789)
# Access item fields: item.id, item.content, item.fields, etc.

# Update a project item (single field)
{:ok, updated_item} = GitHub.Projects.Org.update_item(client, "my-org", 1, 789, %{
  fields: [
    %{id: 101, value: "In Progress"}
  ]
})

# Update multiple fields
{:ok, updated_item} = GitHub.Projects.Org.update_item(client, "my-org", 1, 789, %{
  fields: [
    %{id: 101, value: "In Progress"},
    %{id: 102, value: 42},
    %{id: 103, value: "2025-12-31"}
  ]
})

# Clear a field (set to null)
{:ok, updated_item} = GitHub.Projects.Org.update_item(client, "my-org", 1, 789, %{
  fields: [
    %{id: 101, value: nil}
  ]
})

# Delete an item
:ok = GitHub.Projects.Org.delete_item(client, "my-org", 1, 789)
```

#### Project Items (User-Owned)

The API is identical for user-owned projects, just use `GitHub.Projects.User` instead:

```elixir
# List items
{:ok, items} = GitHub.Projects.User.list_items(client, "octocat", 1)

# Add an item
{:ok, item} = GitHub.Projects.User.add_item(client, "octocat", 1, %{
  type: "Issue",
  id: 123
})

# Get an item
{:ok, item} = GitHub.Projects.User.get_item(client, "octocat", 1, 456)

# Update an item
{:ok, updated_item} = GitHub.Projects.User.update_item(client, "octocat", 1, 456, %{
  fields: [%{id: 789, value: "Done"}]
})

# Delete an item
:ok = GitHub.Projects.User.delete_item(client, "octocat", 1, 456)
```

#### Required Permissions

**For organization-owned projects:**
- **Read operations** (list, get): "Projects" organization permissions (read)
- **Write operations** (add, update, delete): "Projects" organization permissions (write)

**For user-owned projects:**
- **Read operations** (list, get): "Projects" permissions (read)
- **Write operations** (add, update, delete): "Projects" permissions (write)

## Error Handling

All functions return `{:ok, result}` on success or `{:error, reason}` on failure:

```elixir
case GitHub.Projects.Org.get_item(client, "my-org", 1, 123) do
  {:ok, item} ->
    IO.puts("Item #{item.id}: #{inspect(item.content)}")

  {:error, %{status: 404, body: body}} ->
    IO.puts("Item not found: #{inspect(body)}")

  {:error, %{status: 401, body: _}} ->
    IO.puts("Authentication failed")

  {:error, reason} ->
    IO.puts("Request failed: #{inspect(reason)}")
end
```

## Working with Project Items

The `GitHub.Projects.ProjectItem` struct contains:

- `id` - Item ID
- `node_id` - GraphQL node ID
- `project_url` - URL of the project
- `content` - The issue/PR content (map)
- `content_type` - Type of content ("Issue", "PullRequest", "DraftIssue")
- `creator` - User who created the item
- `created_at`, `updated_at`, `archived_at` - Timestamps
- `item_url` - URL of the item
- `fields` - Custom field values (list of maps)

Example:

```elixir
{:ok, item} = GitHub.Projects.Org.get_item(client, "my-org", 1, 123)

IO.puts("Item ID: #{item.id}")
IO.puts("Content type: #{item.content_type}")
IO.puts("Issue number: #{item.content["number"]}")
IO.puts("Created: #{item.created_at}")
```

## API Version

This client uses GitHub API version `2022-11-28`.

## Documentation

Full documentation is available on [HexDocs](https://hexdocs.pm/github_client) or by running:

```bash
mix docs
```

## Development

```bash
# Get dependencies
mix deps.get

# Run tests
mix test

# Generate documentation
mix docs

# Format code
mix format
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [GitHub Projects v2 API](https://docs.github.com/en/rest/projects/items)
- [GitHub API Authentication](https://docs.github.com/en/rest/authentication)
- [Tesla HTTP Client](https://github.com/elixir-tesla/tesla)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Roadmap

This client currently supports:
- ✅ Projects v2 API
  - ✅ Projects (list and retrieve)
  - ✅ Project Fields (list and retrieve)
  - ✅ Project Items (full CRUD for organization and user-owned projects)

Future additions will include:
- 🔲 Repositories API
- 🔲 Issues API
- 🔲 Pull Requests API
- 🔲 Actions API
- 🔲 And more...
