defmodule ExBankID.Json.Default do
  @moduledoc """
  This is the default implementation of ExBankID.Json.Handler based on poison
  """
  @behaviour ExBankID.Json.Handler

  @spec decode(String.t(), struct()) :: {:ok, struct()} | {:error, String.t()}
  def decode(json, target) do
    Poison.decode(json, as: target)
    |> handle_decode_json()
  end

  @spec decode(String.t()) :: {:ok, struct()} | {:error, String.t()}
  def decode(json) do
    json
    |> Poison.decode()
    |> handle_decode_json()
  end

  defp handle_decode_json({:ok, struct}), do: {:ok, struct}
  defp handle_decode_json({:error, :invalid}), do: {:error, "invalid json"}
  defp handle_decode_json({:error, {:invalid, reason}}), do: {:error, reason}
  defp handle_decode_json({:error, {:invalid, reason, _pos}}), do: {:error, reason}

  @type payloads ::
          %ExBankID.Auth.Payload{}
          | %ExBankID.Sign.Payload{}
          | %ExBankID.Collect.Payload{}
          | %ExBankID.Cancel.Payload{}
  @spec encode!(payloads()) :: String.t()
  def encode!(payload) do
    Poison.encode!(payload)
  end
end
