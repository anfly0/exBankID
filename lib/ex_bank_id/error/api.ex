defmodule ExBankID.Error.Api do
  @moduledoc """
  Provides the struct use to represent a response from the BankID api that has http code 400 - 500.
  """
  defstruct errorCode: nil, details: nil
end
