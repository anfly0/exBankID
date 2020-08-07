defmodule ExBankID.HttpRequest do
  @base_url "https://appapi2.test.bankid.com/rp/v5.1/"
  @cert_file __DIR__ <> "/../../assets/test.pem"
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
    HTTPoison.post(
      url(action, opts),
      encode_payload(payload),
      @headers,
      ssl: ssl_options(opts)
    )
    |> handle_response(action)
  end

  defp url(:auth, opts), do: Keyword.get(opts, :url, @base_url) <> "/auth"
  defp url(:sign, opts), do: Keyword.get(opts, :url, @base_url) <> "/sign"
  defp url(:collect, opts), do: Keyword.get(opts, :url, @base_url) <> "/collect"
  defp url(:cancel, opts), do: Keyword.get(opts, :url, @base_url) <> "/cancel"

  defp ssl_options(opts), do: [certfile: Keyword.get(opts, :cert_file, @cert_file)]

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, :collect) do
    Poison.decode(body, as: %ExBankID.Collect.Response{})
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, :auth) do
    Poison.decode(body, as: %ExBankID.Auth.Response{})
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, :sign) do
    Poison.decode(body, as: %ExBankID.Sign.Response{})
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, :cancel) do
    Poison.decode(body)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, _) do
    case Poison.decode(body, as: %ExBankID.Error.Api{}) do
      {:ok, data} ->
        {:error, data}

      {:error, _} ->
        {:error, "Http code #{code}, could not decode body"}
    end
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}, _) do
    {:error, reason}
  end

  defp encode_payload(payload) do
    payload
    |> Map.from_struct()
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
    |> Poison.encode!()
  end
end
