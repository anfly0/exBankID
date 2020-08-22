defmodule ExBankID.Http.Default do
  @moduledoc """
  HTTPoison implementation of the ExBankID.Http.Client behaviour.
  """

  @behaviour ExBankID.Http.Client
  alias ExBankID.Http.Response

  def post(url, req_body, headers, cert_file, http_opts \\ []) do
    opts = Keyword.put(http_opts, :ssl, certfile: cert_file)

    case HTTPoison.post(url, req_body, headers, opts) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:ok, %Response{status_code: code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
