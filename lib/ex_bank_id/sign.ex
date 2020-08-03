defmodule ExBankID.Sign do
  alias ExBankID.Sign

  def sign(ip_address, user_visible_data, opts \\ [])
      when is_binary(ip_address) and is_binary(user_visible_data) and is_list(opts) do
    with payload = %Sign.Payload{} <- Sign.Payload.new(ip_address, user_visible_data, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
