defmodule ExBankID.Collect do
  alias ExBankID.Collect.Payload

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
  def collect(token, opts \\ [])

  def collect(token, opts) when is_binary(token) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def collect(token = %ExBankID.Auth.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def collect(token = %ExBankID.Sign.Response{}, opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
