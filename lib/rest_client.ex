defmodule RestClient do
  def create do
    %{}
  end

  # TODO: share request tracking logic between nullable and non-nullable
  def get(%{null: true, responses: [response | rest]} = client, opts) do
    host = Keyword.get(opts, :host, "null host")
    path = Keyword.get(opts, :path, "null path")
    client = Map.put(client, :last_request, %{host: host, path: path})

    {Map.put(client, :responses, rest), %{status_code: 200, body: response}}
  end

  def get(client, host: host, port: port, path: path, headers: headers) do
    {client, HTTPoison.get!("http://#{host}:#{port}#{path}", headers)}
  end

  def create_null(opts \\ []) do
    responses = Keyword.get(opts, :responses, ["Hello World"])
    %{null: true, responses: responses}
  end
end
