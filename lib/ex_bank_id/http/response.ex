defmodule ExBankID.Http.Response do
  @doc false
  @type t() :: %__MODULE__{status_code: pos_integer(), body: String.t()}
  @enforce_keys [:status_code, :body]
  defstruct [:status_code, :body]
end
