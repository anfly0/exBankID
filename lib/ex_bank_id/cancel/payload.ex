defmodule ExBankID.Cancel.Payload do
  @moduledoc """
  Provides the struct used when requesting to cancel a pending authentication or signing
  """
  defstruct [:orderRef]

  @doc """
  Returns a Cancel Payload given a orderRef, Auth response struct or Sign response struct

  ## Examples
      iex> ExBankID.Cancel.Payload.new("131daac9-16c6-4618-beb0-365768f37288")
      %ExBankID.Cancel.Payload{orderRef: "131daac9-16c6-4618-beb0-365768f37288"}

      iex> ExBankID.Cancel.Payload.new("Not-a-valid-UUID")
      {:error, "OrderRef is not a valid UUID"}

      iex> %ExBankID.Auth.Response{orderRef: "131daac9-16c6-4618-beb0-365768f37288"} |> ExBankID.Cancel.Payload.new()
      %ExBankID.Cancel.Payload{orderRef: "131daac9-16c6-4618-beb0-365768f37288"}

      iex> %ExBankID.Sign.Response{orderRef: "131daac9-16c6-4618-beb0-365768f37288"} |> ExBankID.Cancel.Payload.new()
      %ExBankID.Cancel.Payload{orderRef: "131daac9-16c6-4618-beb0-365768f37288"}
  """
  @spec new(binary | %ExBankID.Auth.Response{} | %ExBankID.Sign.Response{}) ::
          {:error, String.t()} | %__MODULE__{orderRef: String.t()}
  def new(%ExBankID.Auth.Response{orderRef: order_ref}) when is_binary(order_ref) do
    %ExBankID.Cancel.Payload{}
    |> set_order_ref(order_ref)
  end

  def new(%ExBankID.Sign.Response{orderRef: order_ref}) when is_binary(order_ref) do
    %ExBankID.Cancel.Payload{}
    |> set_order_ref(order_ref)
  end

  def new(order_ref) when is_binary(order_ref) do
    %ExBankID.Cancel.Payload{}
    |> set_order_ref(order_ref)
  end

  defp set_order_ref(payload, order_ref) do
    case UUID.info(order_ref) do
      {:ok, _} ->
        %{payload | orderRef: order_ref}

      _ ->
        {:error, "OrderRef is not a valid UUID"}
    end
  end
end
