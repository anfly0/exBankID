defmodule ExBankID do
  @moduledoc """
  Simple abstraction over the swedish BankID API.
  """

  defdelegate auth(ip_address, opts \\ []), to: ExBankID.Auth

  defdelegate collect(order_ref, opts \\ []), to: ExBankID.Collect

  defdelegate sign(ip_address, user_visible_data, opts \\ []), to: ExBankID.Sign

  defdelegate cancel(order_ref, opts \\ []), to: ExBankID.Cancel
end
