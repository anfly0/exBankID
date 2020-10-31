defmodule ExBankID.Sign do
  alias ExBankID.Sign

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
          "This option can be used to specify the personal number of the person signing. See:  [BankID Relying party guidelines section 14.1](https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf)"
        # TODO: Add validator
      ],
      requirement: [
        doc:
          "See: [BankID Relying party guidelines section 14.5](https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf)"
      ],
      user_non_visible_data: [
        type: :string,
        doc:
          "Typically used to include a hash/digest of a document that is to be signed. See: [BankID Relying party guidelines section 12](https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf)"
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

  def sign(ip_address, user_visible_data, opts \\ [])
      when is_binary(ip_address) and is_binary(user_visible_data) and is_list(opts) do
    with {:ok, opts} <- NimbleOptions.validate(opts, options()),
         payload = %Sign.Payload{} <- Sign.Payload.new(ip_address, user_visible_data, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
