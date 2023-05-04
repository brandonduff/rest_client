defmodule RestClient do
  def get(host: host, port: port, path: path, headers: headers) do
   HTTPoison.get!("http://#{host}:#{port}#{path}", headers)
  end
end
