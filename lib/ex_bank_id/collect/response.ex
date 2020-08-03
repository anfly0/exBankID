defmodule ExBankID.Collect.Response do
  alias ExBankID.Collect.CompletionData
  defstruct completionData: %CompletionData{}, orderRef: nil, status: nil, hintCode: nil
end
