defmodule ExBankID.HttpRequest do
  @headers [{"Content-Type", "application/json"}]

  @type payload() ::
          %ExBankID.Auth.Payload{}
          | %ExBankID.Auth.Payload{}
          | %ExBankID.Cancel.Payload{}
          | %ExBankID.Collect.Payload{}
          | %ExBankID.Sign.Payload{}

  @type response() ::
          %ExBankID.Collect.Response{}
          | %ExBankID.Auth.Response{}
          | %ExBankID.Sign.Response{}
          | %{}

  @type opts() :: [url: String.t(), cert_file: String.t()]

  @spec send_request(payload(), opts()) :: {:error, %ExBankID.Error.Api{} | Binary} | {:ok, response()}
  def send_request(payload, opt \\ [])

  def send_request(payload = %ExBankID.Auth.Payload{}, opts) when is_list(opts) do
    do_send_request(:auth, payload, opts)
  end

  def send_request(payload = %ExBankID.Sign.Payload{}, opts) when is_list(opts) do
    do_send_request(:sign, payload, opts)
  end

  def send_request(payload = %ExBankID.Collect.Payload{}, opts) when is_list(opts) do
    do_send_request(:collect, payload, opts)
  end

  def send_request(payload = %ExBankID.Cancel.Payload{}, opts) when is_list(opts) do
    do_send_request(:cancel, payload, opts)
  end

  defp do_send_request(action, payload, opts) do
    client = Keyword.get(opts, :http_client)
    json_handler = Keyword.get(opts, :json_handler)

    client.post(
      url(action, opts),
      encode_payload(payload, json_handler),
      @headers,
      Keyword.get(opts, :cert_file)
    )
    |> handle_response(action, json_handler)
  end

  defp url(:auth, opts), do: Keyword.get(opts, :url) <> "/auth"
  defp url(:sign, opts), do: Keyword.get(opts, :url) <> "/sign"
  defp url(:collect, opts), do: Keyword.get(opts, :url) <> "/collect"
  defp url(:cancel, opts), do: Keyword.get(opts, :url) <> "/cancel"

  defp handle_response({:ok, %ExBankID.Http.Response{status_code: 200, body: body}}, :collect, json_handler) do
    json_handler.decode(body, %ExBankID.Collect.Response{})
  end

  defp handle_response({:ok, %ExBankID.Http.Response{status_code: 200, body: body}}, :auth, json_handler) do
    json_handler.decode(body, %ExBankID.Auth.Response{})
  end

  defp handle_response({:ok, %ExBankID.Http.Response{status_code: 200, body: body}}, :sign, json_handler) do
    json_handler.decode(body, %ExBankID.Sign.Response{})
  end

  defp handle_response({:ok, %ExBankID.Http.Response{status_code: 200, body: body}}, :cancel, json_handler) do
    json_handler.decode(body)
  end

  defp handle_response({:ok, %ExBankID.Http.Response{status_code: code, body: body}}, _, json_handler) do
    case json_handler.decode(body, %ExBankID.Error.Api{}) do
      {:ok, data} ->
        {:error, data}

      {:error, _} ->
        {:error, "Http code #{code}, could not decode body"}
    end
  end

  defp handle_response({:error, reason}, _, _) do
    {:error, reason}
  end

  defp encode_payload(payload, json_handler) do
    payload
    |> Map.from_struct()
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
    |> json_handler.encode!()
  end
end
