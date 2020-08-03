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
end
