defmodule ExBankID.Collect.CompletionData do
  alias ExBankID.Collect.User

  defstruct(
    user: %User{},
    device: %{},
    cert: %{},
    signature: nil,
    ocspResponse: nil
  )
end
