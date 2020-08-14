defmodule ExBankID.Auth do
  @options [
    url: [
      type: :string,
      default: "https://appapi2.test.bankid.com/rp/v5.1/"
    ],
    cert_file: [
      type: :string,
      required: true
    ],
    personal_number: [
      type: :string
      # TODO: Add validator
    ],
    http_client: [
      type: :atom,
      default: Application.get_env(:ex_bank_id, :http_client, ExBankID.Http.Default)
    ]
  ]
  @doc "Supported options:\n#{NimbleOptions.docs(@options)}"

  def auth(ip_address, opts) when is_binary(ip_address) and is_list(opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %ExBankID.Auth.Payload{} <- ExBankID.Auth.Payload.new(ip_address, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
