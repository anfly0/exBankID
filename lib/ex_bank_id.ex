defmodule ExBankID do
  @moduledoc """
  Simple abstraction over the swedish BankID API.
  """

  @doc """
  Initiates a new BankID authentication session.

  Supported options:\n#{NimbleOptions.docs(ExBankID.Auth.options())}
  """

  @spec auth(String.t(), Keyword.t()) ::
          {:error, %ExBankID.Error.Api{} | binary()}
          | {:error, NimbleOptions.ValidationError.t()}
          | {:ok, %ExBankID.Auth.Response{}}
  defdelegate auth(ip_address, opts \\ []), to: ExBankID.Auth

  @doc """
  Initiates a new BankID signing session.

  Supported options:\n#{NimbleOptions.docs(ExBankID.Sign.options())}
  """

  @spec sign(String.t(), String.t(), Keyword.t()) ::
          {:error, %ExBankID.Error.Api{} | binary()}
          | {:error, NimbleOptions.ValidationError.t()}
          | {:ok, %ExBankID.Sign.Response{}}
  defdelegate sign(ip_address, user_visible_data, opts \\ []), to: ExBankID.Sign

  @doc """
  Attempts to collect the status of an ongoing authentication/signing session. See: [BankID Relying party guidelines section 14.2](https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf)

  Supported options:\n#{NimbleOptions.docs(ExBankID.Collect.options())}
  """
  @spec collect(String.t() | %ExBankID.Sign.Response{} | %ExBankID.Auth.Response{}, Keyword.t()) ::
          {:error, %ExBankID.Error.Api{} | binary()}
          | {:error, NimbleOptions.ValidationError.t()}
          | {:ok, %ExBankID.Collect.Response{}}
  defdelegate collect(order_ref, opts \\ []), to: ExBankID.Collect

  @doc """
  Attempts to cancel a ongoing authentication/signing session.

  Supported options:\n#{NimbleOptions.docs(ExBankID.Cancel.options())}
  """
  @spec cancel(String.t() | %ExBankID.Sign.Response{} | %ExBankID.Auth.Response{}, Keyword.t()) ::
          {:error, %ExBankID.Error.Api{} | binary()}
          | {:error, NimbleOptions.ValidationError.t()}
          | {:ok, %{}}
  defdelegate cancel(order_ref, opts \\ []), to: ExBankID.Cancel

  @spec static_qr(%ExBankID.Sign.Response{} | %ExBankID.Auth.Response{}) :: <<_::64, _::_*8>>
  defdelegate static_qr(response), to: ExBankID.Qr
end
