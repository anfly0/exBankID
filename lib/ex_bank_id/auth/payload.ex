defmodule ExBankID.Auth.Payload do
  @moduledoc """
  Provides the struct used when initiating a authentication
  """
  defstruct [:endUserIp, :personalNumber]

  @type reason :: binary()

  @spec new(binary, Keyword.t()) ::
          {:error, reason} | %__MODULE__{endUserIp: binary, personalNumber: binary() | nil}
  @doc """
  Returns a Payload struct containing the given ip address and personal number.

  ## Examples
      iex> ExBankID.Auth.Payload.new("1.1.1.1")
      %ExBankID.Auth.Payload{endUserIp: "1.1.1.1"}

      iex> ExBankID.Auth.Payload.new("qwerty")
      {:error, "Invalid ip address: qwerty"}

      iex> ExBankID.Auth.Payload.new("1.1.1.1", [personal_number: "190000000000"])
      %ExBankID.Auth.Payload{endUserIp: "1.1.1.1", personalNumber: "190000000000"}

      iex> ExBankID.Auth.Payload.new("1.1.1.1", [personal_number: "Not a personal number"])
      {:error, "Invalid personal number"}
  """
  def new(ip_address, opts \\ []) when is_binary(ip_address) and is_list(opts) do
    with {:ok, ip_address} <- check_ip_address(ip_address),
         {:ok, personal_number} <- check_personal_number(Keyword.get(opts, :personal_number)) do
      %__MODULE__{endUserIp: ip_address, personalNumber: personal_number}
    end
  end

  defp check_ip_address(ip_address)
       when is_binary(ip_address) do
    ip_address_cl = String.to_charlist(ip_address)

    case :inet.parse_strict_address(ip_address_cl) do
      {:ok, _} ->
        {:ok, ip_address}

      _ ->
        {:error, "Invalid ip address: #{ip_address}"}
    end
  end

  defp check_personal_number(personal_number)
       when is_binary(personal_number) do
    # TODO: Implement relevant personal number check.
    case String.length(personal_number) do
      12 ->
        {:ok, personal_number}

      _ ->
        {:error, "Invalid personal number"}
    end
  end

  defp check_personal_number(nil) do
    {:ok, nil}
  end
end
