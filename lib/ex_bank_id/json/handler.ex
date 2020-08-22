defmodule ExBankID.Json.Handler do
  @moduledoc """
  The expected behaviour a module capable of encoding and decoding json
  """

  @doc """
  An implementation of this should decode the json string into the given struct.
  Keys missing in the json string should not result in an error.
  """
  @callback decode(json :: String.t(), target :: struct()) :: {:ok, struct()} | {:error, String.t()}

  @doc """
  An implementation of this should decode the given json string to the equivalent elixir value.
  """
  @callback decode(json :: String.t()) :: {:ok, any} | {:error, String.t()}

  @callback encode!(payload :: struct()) :: String.t()
end
