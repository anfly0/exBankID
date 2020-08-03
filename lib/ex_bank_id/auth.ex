defmodule ExBankID.Auth do
  def auth(ip_address, opts)
      when is_binary(ip_address) and is_list(opts) do
    with payload = %ExBankID.Auth.Payload{} <-
           ExBankID.Auth.Payload.new(ip_address, opts) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
