defmodule Test.Static.Qr do
  use ExUnit.Case, async: true

  test "Static qr-code from auth response" do
    response = %ExBankID.Auth.Response{
      orderRef: "131daac9-16c6-4618-beb0-365768f37288",
      autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
      qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
      qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
    }

    assert "bankid:///?autostarttoken=7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6" =
             ExBankID.static_qr(response)
  end

  test "Static qr-code from sign response" do
    response = %ExBankID.Sign.Response{
      orderRef: "131daac9-16c6-4618-beb0-365768f37288",
      autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
      qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
      qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
    }

    assert "bankid:///?autostarttoken=7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6" =
             ExBankID.static_qr(response)
  end
end
