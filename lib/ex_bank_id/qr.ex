defmodule ExBankID.Qr do
  @static_token_prefix "bankid:///?autostarttoken="

  def static_qr(%ExBankID.Auth.Response{autoStartToken: token}) do
    @static_token_prefix <> token
  end

  def static_qr(%ExBankID.Sign.Response{autoStartToken: token}) do
    @static_token_prefix <> token
  end
end
