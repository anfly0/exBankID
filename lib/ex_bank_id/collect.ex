defmodule ExBankID.Collect do
  alias ExBankID.Collect.Payload

  def options() do
    [
      url: [
        type: :string,
        default:
          Application.get_env(:ex_bank_id, :url, "https://appapi2.test.bankid.com/rp/v5.1/")
      ],
      cert_file: [
        type: :string,
        default:
          Application.get_env(:ex_bank_id, :cert_file, __DIR__ <> "/../../assets/test.pem"),
        doc:
          "If no certificate path is specified, the publicly available test certificate will be used."
      ],
      http_client: [
        type: :atom,
        default: Application.get_env(:ex_bank_id, :http_client, ExBankID.Http.Default),
        doc:
          "Specify a custom http client. Should be a module that implements ExBankID.Http.Client."
      ],
      json_handler: [
        type: :atom,
        default: Application.get_env(:ex_bank_id, :json_handler, ExBankID.Json.Default),
        doc:
          "Specify a custom json handler. Should be a module that implements ExBankID.Json.Handler."
      ]
    ]
  end

  def collect(token, opts \\ [])

  def collect(token, opts) when is_binary(token) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def collect(token = %ExBankID.Auth.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def collect(token = %ExBankID.Sign.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
