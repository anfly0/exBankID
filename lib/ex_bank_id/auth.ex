defmodule ExBankID.Auth do
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
      personal_number: [
        type: :string
        # TODO: Add validator
      ],
      http_client: [
        type: :atom,
        default: Application.get_env(:ex_bank_id, :http_client, ExBankID.Http.Default)
      ],
      json_handler: [
        type: :atom,
        default: Application.get_env(:ex_bank_id, :json_handler, ExBankID.Json.Default)
      ]
    ]
  end

  def auth(ip_address, opts) when is_binary(ip_address) and is_list(opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %ExBankID.Auth.Payload{} <- ExBankID.Auth.Payload.new(ip_address, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
