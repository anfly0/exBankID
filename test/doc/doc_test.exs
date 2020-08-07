defmodule ExBankID.Auth.PayloadTest do
  use ExUnit.Case, async: true
  doctest ExBankID.Auth.Payload
  doctest ExBankID.Sign.Payload
  doctest ExBankID.Cancel.Payload
end
