defmodule ExBankID.Auth.Response do
  @moduledoc """
  Provides the struct used to represent the response from a successful request to the BankID /auth endpoint
  """
  defstruct [:orderRef, :autoStartToken, :qrStartToken, :qrStartSecret]
end
