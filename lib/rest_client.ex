defmodule RestClient do
  def create do
    %{}
  end

  def get(%{null: true, responses: [response | rest]} = client, _opts) do
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
