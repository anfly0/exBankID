defmodule ExBankID.Sign.Payload do
  @moduledoc """
  Provides the struct used when initiating a signing of data
  """
  defstruct [:endUserIp, :personalNumber, :requirement, :userVisibleData, :userNonVisibleData]

  import ExBankID.PayloadHelpers

  @spec new(
          binary,
          binary,
          personal_number: String.t(),
          requirement: map(),
          user_non_visible_data: String.t()
        ) ::
          {:error, String.t()} | %ExBankID.Sign.Payload{}
  @doc """
  Constructs a new Sign Payload with the given ip-address, user visible data, and optionally personal number and user non visible data.
  user_visible_data and user_non_visible_data will be properly encode

  ## Examples
      iex> ExBankID.Sign.Payload.new("1.1.1.1", "This will be visible in the bankID app")
      %ExBankID.Sign.Payload{endUserIp: "1.1.1.1", userVisibleData: "VGhpcyB3aWxsIGJlIHZpc2libGUgaW4gdGhlIGJhbmtJRCBhcHA="}

      iex> ExBankID.Sign.Payload.new("1.1.1.1", "This will be visible in the bankID app", personal_number: "190000000000")
      %ExBankID.Sign.Payload{endUserIp: "1.1.1.1", personalNumber: "190000000000", userVisibleData: "VGhpcyB3aWxsIGJlIHZpc2libGUgaW4gdGhlIGJhbmtJRCBhcHA="}

      iex> ExBankID.Sign.Payload.new("1.1.1.1", "This will be visible in the bankID app", requirement: %{allowFingerprint: :false})
      %ExBankID.Sign.Payload{endUserIp: "1.1.1.1", userVisibleData: "VGhpcyB3aWxsIGJlIHZpc2libGUgaW4gdGhlIGJhbmtJRCBhcHA=", requirement: %{allowFingerprint: :false}}

      iex> ExBankID.Sign.Payload.new("Not a valid ip address", "This will be visible in the bankID app", personal_number: "190000000000")
      {:error, "Invalid ip address: Not a valid ip address"}
  """
  def new(ip_address, user_visible_data, opts \\ [])
      when is_binary(ip_address) and is_binary(user_visible_data) and is_list(opts) do
    with {:ok, ip_address} <- check_ip_address(ip_address),
         {:ok, user_visible_data} <- encode_user_visible_data(user_visible_data),
         {:ok, personal_number} <- check_personal_number(Keyword.get(opts, :personal_number)),
         {:ok, user_non_visible_data} <-
           encode_user_non_visible_data(Keyword.get(opts, :user_non_visible_data)),
         {:ok, requirement} <- check_requirement(Keyword.get(opts, :requirement)) do
      %ExBankID.Sign.Payload{
        endUserIp: ip_address,
        userVisibleData: user_visible_data,
        personalNumber: personal_number,
        requirement: requirement,
        userNonVisibleData: user_non_visible_data
      }
    end
  end

  defp encode_user_visible_data(data) when is_binary(data) do
    data = Base.encode64(data)

    if byte_size(data) < 40_000 do
      {:ok, data}
    else
      {:error, "User visible data is to large"}
    end
  end

  defp encode_user_non_visible_data(data) when is_binary(data) do
    data = Base.encode64(data)

    if byte_size(data) < 200_000 do
      {:ok, data}
    else
      {:error, "User visible data is to large"}
    end
  end

  defp encode_user_non_visible_data(nil) do
    {:ok, nil}
  end
end
