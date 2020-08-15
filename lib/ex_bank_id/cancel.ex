defmodule ExBankID.Cancel do
  alias ExBankID.Cancel.Payload

  defp options() do
    [
      url: [
        type: :string,
        default: Application.get_env(:ex_bank_id, :url, "https://appapi2.test.bankid.com/rp/v5.1/")
      ],
      cert_file: [
        type: :string,
        default: Application.get_env(:ex_bank_id, :cert_file, __DIR__ <> "/../../assets/test.pem")
      ],
      http_client: [
        type: :atom,
        default: Application.get_env(:ex_bank_id, :http_client, ExBankID.Http.Default)
      ]
    ]
  end

  def cancel(token, opts \\ [])

  def cancel(token, opts) when is_binary(token) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def cancel(token = %ExBankID.Auth.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def cancel(token = %ExBankID.Sign.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
