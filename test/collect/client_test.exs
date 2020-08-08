defmodule Test.Auth.Collect do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "Client can collect pending order", %{bypass: bypass} do
    expected_response =
      {:ok,
       %ExBankID.Collect.Response{
         orderRef: "131daac9-16c6-4618-beb0-365768f37288",
         status: "Pending",
         hintCode: "userSign"
       }}

    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}

    response_payload = ~s<{
    "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
    "status": "Pending",
    "hintCode": "userSign"
    }>

    Bypass.expect_once(
      bypass,
      "POST",
      "/collect",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.collect("131daac9-16c6-4618-beb0-365768f37288",
               url: Test.Helpers.get_url(bypass.port())
             )
  end

  test "Client can collect pending order auth response as argument", %{bypass: bypass} do
    expected_response =
      {:ok,
       %ExBankID.Collect.Response{
         orderRef: "131daac9-16c6-4618-beb0-365768f37288",
         status: "pending",
         hintCode: "userSign"
       }}

    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}

    response_payload = ~s<{"orderRef":"131daac9-16c6-4618-beb0-365768f37288","status":"pending","hintCode":"userSign"}>

    Bypass.expect_once(
      bypass,
      "POST",
      "/collect",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.collect(
               %ExBankID.Auth.Response{
                 orderRef: "131daac9-16c6-4618-beb0-365768f37288",
                 autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
                 qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
                 qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
               },
               url: Test.Helpers.get_url(bypass.port())
             )
  end

  # TODO: Refactor this test to have the same structure as the other ones.
  test "Client can collect pending order sign response as argument", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/collect", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        ~s<{"orderRef":"131daac9-16c6-4618-beb0-365768f37288","status":"pending","hintCode":"userSign"}>
      )
    end)

    assert {:ok,
            %ExBankID.Collect.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              status: "pending",
              hintCode: "userSign"
            }} =
             ExBankID.collect(
               %ExBankID.Sign.Response{
                 orderRef: "131daac9-16c6-4618-beb0-365768f37288",
                 autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
                 qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
                 qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
               },
               url: Test.Helpers.get_url(bypass.port())
             )
  end

  # TODO: Refactor this test to have the same structure as the other ones.
  test "Client can collect completed order", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/collect", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        ~s<{
          "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
          "status": "complete",
          "completionData": {
              "user": {
                  "personalNumber": "190000000000",
                  "name": "Karl Karlsson",
                  "givenName": "Karl",
                  "surname": "Karlsson"
              },
              "device": {
                  "ipAddress": "192.168.0.1"
              },
              "cert": {
                  "notBefore": "1502983274000",
                  "notAfter": "1563549674000"
              },
              "signature": "base64-encoded data",
              "ocspResponse": "base64-encoded data"
          }
      }>
      )
    end)

    assert {:ok, %ExBankID.Collect.Response{}} =
             ExBankID.collect(
               %ExBankID.Sign.Response{
                 orderRef: "131daac9-16c6-4618-beb0-365768f37288",
                 autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
                 qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
                 qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
               },
               url: Test.Helpers.get_url(bypass.port())
             )
  end
end
