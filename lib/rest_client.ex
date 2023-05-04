defmodule RestClient do
  def create do
    %{}
  end

  def get(%{null: true}, _opts) do
    %{status_code: 200}
  end

  def get(_client, host: host, port: port, path: path, headers: headers) do
    HTTPoison.get!("http://#{host}:#{port}#{path}", headers)
  end

  def create_null do
    %{null: true}
  end
end
