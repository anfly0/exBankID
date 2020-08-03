defmodule ExBankID.Collect do
  def collect(token, opts \\ [])

  def collect(token, opts) when is_binary(token) do
    with payload = %ExBankID.Collect.Payload{} <-
           ExBankID.Collect.Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def collect(token = %ExBankID.Auth.Response{}, opts) do
    with payload = %ExBankID.Collect.Payload{} <-
           ExBankID.Collect.Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end

  def collect(token = %ExBankID.Sign.Response{}, opts) do
    with payload = %ExBankID.Collect.Payload{} <-
           ExBankID.Collect.Payload.new(token) do
      ExBankID.HttpRequest.send_request(payload, opts)
    end
  end
end
