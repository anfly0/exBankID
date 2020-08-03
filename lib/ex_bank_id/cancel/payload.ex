defmodule ExBankID.Cancel.Payload do
  @moduledoc """
  Provides the struct used when requesting to cancel a pending authentication or signing
  """
  defstruct [:orderRef]

  @spec new(binary | ExBankID.Auth.Response.t()) ::
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
