defmodule ExBankID.Cancel do
  alias ExBankID.Cancel.Payload
  def cancel(token, opts \\ [])

  def cancel(token, opts) when is_binary(token) do
    with payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def cancel(token = %ExBankID.Auth.Response{}, opts) do
    with payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def cancel(token = %ExBankID.Sign.Response{}, opts) do
    with payload = %Payload{} <-
           Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
