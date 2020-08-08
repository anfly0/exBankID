defmodule ExBankID.Sign.Payload do
  @moduledoc """
  Provides the struct used when initiating a signing of data
  """
  defstruct [:endUserIp, :personalNumber, :userVisibleData, :userNonVisibleData]

  @spec new(
          binary,
          binary,
          personal_number: String.t(),
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

    iex> ExBankID.Sign.Payload.new("Not a valid ip address", "This will be visible in the bankID app", personal_number: "190000000000")
    {:error, "Invalid ip address Not a valid ip address"}
  """
  def new(ip_address, user_visible_data, opts \\ [])
      when is_binary(ip_address) and is_binary(user_visible_data) and is_list(opts) do
    with {:ok, ip_address} <- check_ip_address(ip_address),
         {:ok, user_visible_data} <- encode_user_visible_data(user_visible_data),
         {:ok, personal_number} <- check_personal_number(Keyword.get(opts, :personal_number)),
         {:ok, user_non_visible_data} <-
           encode_user_non_visible_data(Keyword.get(opts, :user_non_visible_data)) do
      %ExBankID.Sign.Payload{
        endUserIp: ip_address,
        userVisibleData: user_visible_data,
        personalNumber: personal_number,
        userNonVisibleData: user_non_visible_data
      }
    end
  end

  defp check_ip_address(ip_address)
       when is_binary(ip_address) do
    ip_address_cl = String.to_charlist(ip_address)

    case :inet.parse_strict_address(ip_address_cl) do
      {:ok, _} ->
        {:ok, ip_address}

      _ ->
        {:error, "Invalid ip address #{ip_address}"}
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
