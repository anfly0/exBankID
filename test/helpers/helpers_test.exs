defmodule Test.Helpers do
  def get_url(port), do: "http://localhost:#{port}"

  def endpoint_handler(http_code, response, expected_request_payload) do
    fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      {:ok, ^expected_request_payload} = Poison.decode(body)

      Plug.Conn.resp(
        conn,
        http_code,
        response
      )
    end
  end

  def cert_file(), do: __DIR__ <> "../../assets/test.pem"
end
