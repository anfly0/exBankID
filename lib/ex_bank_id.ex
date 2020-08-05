defmodule ExBankID do
  @moduledoc """
  Simple abstraction over the swedish BankID API.
  """

  @spec auth(String.t(), url: String.t(), cert_file: String.t()) ::
          {:error, %ExBankID.Error.Api{} | binary()} | {:ok, %ExBankID.Auth.Response{}}
  defdelegate auth(ip_address, opts \\ []), to: ExBankID.Auth

  @spec sign(String.t(), String.t(),
          url: String.t(),
          cert_file: String.t(),
          personal_number: String.t(),
          user_non_visible_data: String.t()
        ) :: {:error, %ExBankID.Error.Api{} | binary()} | {:ok, %ExBankID.Sign.Response{}}
  defdelegate sign(ip_address, user_visible_data, opts \\ []), to: ExBankID.Sign

  @spec collect(String.t() | %ExBankID.Sign.Response{} | %ExBankID.Auth.Response{},
          url: String.t(),
          cert_file: String.t()
        ) ::
          {:error, %ExBankID.Error.Api{} | binary()} | {:ok, %ExBankID.Collect.Response{}}
  defdelegate collect(order_ref, opts \\ []), to: ExBankID.Collect

  @spec cancel(String.t() | %ExBankID.Sign.Response{} | %ExBankID.Auth.Response{},
          url: String.t(),
          cert_file: String.t()
        ) :: {:error, %ExBankID.Error.Api{} | binary()} | {:ok, %{}}
  defdelegate cancel(order_ref, opts \\ []), to: ExBankID.Cancel
end
