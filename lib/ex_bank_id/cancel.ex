defmodule ExBankID.Cancel do
  alias ExBankID.Cancel.Payload

  @options [
    url: [
      type: :string,
      default: "https://appapi2.test.bankid.com/rp/v5.1/"
    ],
    cert_file: [
      type: :string,
      required: true
    ]
  ]
  def cancel(token, opts \\ [])

  def cancel(token, opts) when is_binary(token) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def cancel(token = %ExBankID.Auth.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def cancel(token = %ExBankID.Sign.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
