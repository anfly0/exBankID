defmodule Test.Json.Default do
  use ExUnit.Case, async: true

  test "Decoding auth response" do
    json = ~s<{
      "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
      "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
      "qrStartToken": "67df3917-fa0d-44e5-b327-edcc928297f8",
      "qrStartSecret": "d28db9a7-4cde-429e-a983-359be676944c"
      }>

    assert {:ok,
            %ExBankID.Auth.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
              qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
            }} = ExBankID.Json.Default.decode(json, %ExBankID.Auth.Response{})
  end

  test "Decoding auth response api v5" do
    json = ~s<{
      "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
      "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6"
      }>

    assert {:ok,
            %ExBankID.Auth.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: nil,
              qrStartSecret: nil
            }} = ExBankID.Json.Default.decode(json, %ExBankID.Auth.Response{})
  end

  test "Decoding sign response" do
    json = ~s<{
      "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
      "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
      "qrStartToken": "67df3917-fa0d-44e5-b327-edcc928297f8",
      "qrStartSecret": "d28db9a7-4cde-429e-a983-359be676944c"
      }>

    assert {:ok,
            %ExBankID.Sign.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
              qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
            }} = ExBankID.Json.Default.decode(json, %ExBankID.Sign.Response{})
  end

  test "Decoding sign response api v5" do
    json = ~s<{
      "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
      "autoStartToken": "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6"
      }>

    assert {:ok,
            %ExBankID.Sign.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
              qrStartToken: nil,
              qrStartSecret: nil
            }} = ExBankID.Json.Default.decode(json, %ExBankID.Sign.Response{})
  end

  test "Decoding collect response" do
    json = ~s<{
      "orderRef": "131daac9-16c6-4618-beb0-365768f37288",
      "status": "Pending",
      "hintCode": "userSign"
      }>

    assert {:ok,
            %ExBankID.Collect.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              status: "Pending",
              hintCode: "userSign"
            }} = ExBankID.Json.Default.decode(json, %ExBankID.Collect.Response{})
  end

  test "Decoding collect response with completion data" do
    json = ~s<{
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

    assert {:ok,
            %ExBankID.Collect.Response{
              orderRef: "131daac9-16c6-4618-beb0-365768f37288",
              status: "complete",
              completionData: %ExBankID.Collect.CompletionData{
                user: %ExBankID.Collect.User{
                  personalNumber: "190000000000",
                  name: "Karl Karlsson",
                  givenName: "Karl",
                  surname: "Karlsson"
                },
                device: %{
                  "ipAddress" => "192.168.0.1"
                },
                cert: %{
                  "notBefore" => "1502983274000",
                  "notAfter" => "1563549674000"
                },
                signature: "base64-encoded data",
                ocspResponse: "base64-encoded data"
              }
            }} = ExBankID.Json.Default.decode(json, %ExBankID.Collect.Response{})
  end

  test "Decode cancel response" do
    json = ~s<{}>

    assert {:ok, %{}} = ExBankID.Json.Default.decode(json)
  end

  test "Encode Auth payload" do
    payload = ExBankID.Auth.Payload.new("1.1.1.1", personal_number: "190000000000")

    assert ^payload = Poison.decode!(ExBankID.Json.Default.encode!(payload), as: %ExBankID.Auth.Payload{})
  end

  test "Encode Sign payload" do
    payload = ExBankID.Sign.Payload.new("1.1.1.1", "some data to sign", personal_number: "190000000000")

    assert ^payload = Poison.decode!(ExBankID.Json.Default.encode!(payload), as: %ExBankID.Sign.Payload{})
  end

  test "Encode Collect payload" do
    payload = ExBankID.Collect.Payload.new("131daac9-16c6-4618-beb0-365768f37288")

    assert ^payload = Poison.decode!(ExBankID.Json.Default.encode!(payload), as: %ExBankID.Collect.Payload{})
  end

  test "Encode Cancel payload" do
    payload = ExBankID.Cancel.Payload.new("131daac9-16c6-4618-beb0-365768f37288")

    assert ^payload = Poison.decode!(ExBankID.Json.Default.encode!(payload), as: %ExBankID.Cancel.Payload{})
  end
end
