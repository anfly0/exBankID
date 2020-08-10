defmodule ExBankID.Sign do
  alias ExBankID.Sign

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
    user_non_visible_data: [
      type: :string
    ]
  ]
  @doc "Supported options:\n#{NimbleOptions.docs(@options)}"

  def sign(ip_address, user_visible_data, opts \\ [])
      when is_binary(ip_address) and is_binary(user_visible_data) and is_list(opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, @options),
         payload = %Sign.Payload{} <- Sign.Payload.new(ip_address, user_visible_data, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
