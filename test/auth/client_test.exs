defmodule Test.Auth.Client do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "client handles successful auth request", %{bypass: bypass} do
    expected_response =
      {:ok,
       %ExBankID.Auth.Response{
         orderRef: "131daac9-16c6-4618-beb0-365768f37288",
         autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
         qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
         qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
       }}

    expected_request_payload = %{"endUserIp" => "1.1.1.1"}

    response_payload = ~s<{
    "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
    "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
    "qrStartToken": "67df3917-fa0d-44e5-b327-edcc928297f8",
    "qrStartSecret": "d28db9a7-4cde-429e-a983-359be676944c"
    }>

    Bypass.expect_once(
      bypass,
      "POST",
      "/auth",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response = ExBankID.auth("1.1.1.1", url: Test.Helpers.get_url(bypass.port()))
  end

  test "client handles successful auth request with personal number", %{bypass: bypass} do
    expected_response =
      {:ok,
       %ExBankID.Auth.Response{
         orderRef: "131daac9-16c6-4618-beb0-365768f37288",
         autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
         qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
         qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
       }}

    expected_request_payload = %{"endUserIp" => "1.1.1.1", "personalNumber" => "190000000000"}

    response_payload = ~s<{
    "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
    "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
    "qrStartToken": "67df3917-fa0d-44e5-b327-edcc928297f8",
    "qrStartSecret": "d28db9a7-4cde-429e-a983-359be676944c"
    }>

    Bypass.expect_once(
      bypass,
      "POST",
      "/auth",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.auth("1.1.1.1",
               url: Test.Helpers.get_url(bypass.port()),
               personal_number: "190000000000"
             )
  end

  test "client handles successful auth request with requirement", %{bypass: bypass} do
    expected_response =
      {:ok,
       %ExBankID.Auth.Response{
         orderRef: "131daac9-16c6-4618-beb0-365768f37288",
         autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
         qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
         qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
       }}

    expected_request_payload = %{
      "endUserIp" => "1.1.1.1",
      "requirement" => %{"allowFingerprint" => true}
    }

    response_payload = ~s<{
    "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
    "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
    "qrStartToken": "67df3917-fa0d-44e5-b327-edcc928297f8",
    "qrStartSecret": "d28db9a7-4cde-429e-a983-359be676944c"
    }>

    Bypass.expect_once(
      bypass,
      "POST",
      "/auth",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.auth("1.1.1.1",
               url: Test.Helpers.get_url(bypass.port()),
               requirement: %{allowFingerprint: true}
             )
  end

  test "client handles unsuccessful auth request", %{bypass: bypass} do
    expected_response =
      {:error, %ExBankID.Error.Api{errorCode: "invalidParameters", details: "No such order"}}

    expected_request_payload = %{"endUserIp" => "1.1.1.1"}

    response_payload = ~s<{
      "errorCode": "invalidParameters",
      "details": "No such order"
    }>

    Bypass.expect_once(
      bypass,
      "POST",
      "/auth",
      Test.Helpers.endpoint_handler(400, response_payload, expected_request_payload)
    )

    assert ^expected_response = ExBankID.auth("1.1.1.1", url: Test.Helpers.get_url(bypass.port()))
  end
end
