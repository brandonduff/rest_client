defmodule RestClientTest do
  use ExUnit.Case
  doctest RestClient

  setup do
    start_supervised({SpyServer, port: 3000})
    :ok
  end

  test "making a get request" do
    client = RestClient.create()

    {_client, response} =
      RestClient.get(client,
        host: 'localhost',
        port: 3000,
        path: '/mypath',
        headers: [{"foo", "bar"}]
      )

    last_request = SpyServer.get_last_request()

    assert response.status_code == 200

    assert last_request.method == "GET"
    assert last_request.path == "/mypath"
    assert Enum.member?(last_request.headers, {"foo", "bar"})
  end

  test "doesn't talk to the network when null" do
    client = RestClient.create_null()

    {_client, response} =
      RestClient.get(client,
        host: 'localhost',
        port: 3000,
        path: '/mypath'
      )

    last_request = SpyServer.get_last_request()

    assert response.status_code == 200
    assert last_request == nil
  end

  test "can have its response configured" do
    client = RestClient.create_null(responses: ["configured response 1", "configured response 2"])

    {client, response} = RestClient.get(client, host: "localhost", port: 3000, path: "/mypath")

    assert response.body == "configured response 1"

    {_client, response} = RestClient.get(client, host: "localhost", port: 3000, path: "/mypath")

    assert response.body == "configured response 2"
  end
end

defmodule SpyServer do
  import Plug.Conn

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(port: port) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: SpyServer, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: SpyServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init(options) do
    Agent.start_link(fn -> nil end, name: SpyServer)
    options
  end

  def get_last_request do
    Agent.get(SpyServer, fn state -> state end)
  end

  def call(conn, _opts) do
    Agent.update(SpyServer, fn _state ->
      %{
        method: conn.method,
        path: conn.request_path,
        headers: conn.req_headers
      }
    end)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World")
  end
end
