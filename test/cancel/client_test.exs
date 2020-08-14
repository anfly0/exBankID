defmodule Test.Cancel.Client do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "Client handles successful cancel request", %{bypass: bypass} do
    expected_response = {:ok, %{}}
    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}
    response_payload = ~s<{}>

    Bypass.expect_once(
      bypass,
      "POST",
      "/cancel",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.cancel("131daac9-16c6-4618-beb0-365768f37288",
               url: Test.Helpers.get_url(bypass.port())
             )
  end

  test "Client handles successful cancel request give a auth response struct", %{bypass: bypass} do
    expected_response = {:ok, %{}}
    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}
    response_payload = ~s<{}>

    Bypass.expect_once(
      bypass,
      "POST",
      "/cancel",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.cancel(%ExBankID.Auth.Response{orderRef: "131daac9-16c6-4618-beb0-365768f37288"},
               url: Test.Helpers.get_url(bypass.port())
             )
  end

  test "Client handles successful cancel request give a sign response struct", %{bypass: bypass} do
    expected_response = {:ok, %{}}
    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}
    response_payload = ~s<{}>

    Bypass.expect_once(
      bypass,
      "POST",
      "/cancel",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.cancel(%ExBankID.Sign.Response{orderRef: "131daac9-16c6-4618-beb0-365768f37288"},
               url: Test.Helpers.get_url(bypass.port())
             )
  end

  test "Client handles cancel request that results in API error", %{bypass: bypass} do
    expected_response = {:error, %ExBankID.Error.Api{errorCode: "invalidParameters", details: "No such order"}}
    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}
    response_payload = ~s<{
      "errorCode": "invalidParameters",
      "details": "No such order"
    }>

    Bypass.expect_once(
      bypass,
      "POST",
      "/cancel",
      Test.Helpers.endpoint_handler(400, response_payload, expected_request_payload)
    )

    assert ^expected_response =
             ExBankID.cancel("131daac9-16c6-4618-beb0-365768f37288",
               url: Test.Helpers.get_url(bypass.port())
             )
  end
end
