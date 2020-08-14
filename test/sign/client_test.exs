defmodule Test.Auth.Sign do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "client handles successful sign request without optional values", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/sign", fn conn ->
      assert {:ok, body, _} = Plug.Conn.read_body(conn)

      assert {:ok, %{"userVisibleData" => "VmlzaWJsZSBkYXRh", "endUserIp" => "1.1.1.1"}} = Poison.decode(body)

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"orderRef":"131daac9-16c6-4618-beb0-365768f37288","autoStartToken":"7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6","qrStartToken":"67df3917-fa0d-44e5-b327-edcc928297f8","qrStartSecret":"d28db9a7-4cde-429e-a983-359be676944c"}>
      )
    end)

    assert {:ok,
            %ExBankID.Sign.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
              qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
            }} = ExBankID.sign("1.1.1.1", "Visible data", url: Test.Helpers.get_url(bypass.port()))
  end

  test "client handles successful sign request with personal number", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/sign", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        ~s<{"orderRef":"131daac9-16c6-4618-beb0-365768f37288","autoStartToken":"7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6","qrStartToken":"67df3917-fa0d-44e5-b327-edcc928297f8","qrStartSecret":"d28db9a7-4cde-429e-a983-359be676944c"}>
      )
    end)

    assert {:ok,
            %ExBankID.Sign.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
              qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
            }} =
             ExBankID.sign("1.1.1.1", "Visible data",
               url: Test.Helpers.get_url(bypass.port()),
               personal_number: "190000000000"
             )
  end

  test "client handles successful sign request with personal number and non visible data", %{
    bypass: bypass
  } do
    Bypass.expect_once(bypass, "POST", "/sign", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        ~s<{"orderRef":"131daac9-16c6-4618-beb0-365768f37288","autoStartToken":"7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6","qrStartToken":"67df3917-fa0d-44e5-b327-edcc928297f8","qrStartSecret":"d28db9a7-4cde-429e-a983-359be676944c"}>
      )
    end)

    assert {:ok,
            %ExBankID.Sign.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
              qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
            }} =
             ExBankID.sign("1.1.1.1", "Visible data",
               url: Test.Helpers.get_url(bypass.port()),
               personal_number: "190000000000",
               user_non_visible_data: "Not visible data"
             )
  end
end
