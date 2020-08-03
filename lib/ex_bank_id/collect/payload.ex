defmodule ExBankID.Collect.Payload do
  defstruct [:orderRef]

  def new(%ExBankID.Auth.Response{orderRef: order_ref}) when is_binary(order_ref) do
    %ExBankID.Collect.Payload{}
    |> set_order_ref(order_ref)
  end

  def new(%ExBankID.Sign.Response{orderRef: order_ref}) when is_binary(order_ref) do
    %ExBankID.Collect.Payload{}
    |> set_order_ref(order_ref)
  end

  def new(order_ref) when is_binary(order_ref) do
    %ExBankID.Collect.Payload{}
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
