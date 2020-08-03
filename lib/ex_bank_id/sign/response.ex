defmodule ExBankID.Sign.Response do
  @moduledoc """
  Provides the struct used to represent the response from a successful request to the BankID /sign endpoint
  """
  defstruct [:orderRef, :autoStartToken, :qrStartToken, :qrStartSecret]
end
