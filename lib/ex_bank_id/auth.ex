defmodule ExBankID.Auth do
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
      personal_number: [
        type: :string,
        doc:
          "This option can be used to specify the personal number of the person authenticating. See:  [BankID Relying party guidelines section 14.1](https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf)"
        # TODO: Add validator
      ],
      requirement: [
        doc:
          "See: [BankID Relying party guidelines section 14.5](https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf)"
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

  def auth(ip_address, opts) when is_binary(ip_address) and is_list(opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %ExBankID.Auth.Payload{} <- ExBankID.Auth.Payload.new(ip_address, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
