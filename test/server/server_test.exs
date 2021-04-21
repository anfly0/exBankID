defmodule Test.Server do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "Starting the server using start_link" do
    assert {:ok, _pid} = ExBankID.Server.start_link()
  end

  test "Fetching the current server state" do
    {:ok, pid} = ExBankID.Server.start_link()
    assert :ready = ExBankID.Server.state(pid)
  end

  test "Fetching the current server data" do
    {:ok, pid} = ExBankID.Server.start_link()
    assert %{init_resp: nil, collect: nil} = ExBankID.Server.data(pid)
  end

  test "Initiate authentication", %{bypass: bypass} do
    {:ok, pid} = ExBankID.Server.start_link(url: Test.Helpers.get_url(bypass.port()))

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

    assert :ok = ExBankID.Server.authenticate(pid, "1.1.1.1")
    assert :authenticating = ExBankID.Server.state(pid)

    assert %{
             init_resp: %ExBankID.Auth.Response{
               orderRef: "131daac9-16c6-4618-beb0-365768f37288",
               autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
               qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
               qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
             }
           } = ExBankID.Server.data(pid)
  end

  test "Server starts collecting the BankID", %{bypass: bypass} do
    {:ok, pid} = ExBankID.Server.start_link(url: Test.Helpers.get_url(bypass.port()))

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

    expected_request_payload = %{"orderRef" => "131daac9-16c6-4618-beb0-365768f37288"}

    response_payload =
      ~s<{"orderRef":"131daac9-16c6-4618-beb0-365768f37288","status":"pending","hintCode":"userSign"}>

    Bypass.expect(
      bypass,
      "POST",
      "/collect",
      Test.Helpers.endpoint_handler(200, response_payload, expected_request_payload)
    )

    self_pid = self()

    state_change_callback = fn from_state, to_state, _data ->
      send(self_pid, {from_state, to_state})
    end

    raise_callback = fn _, _, _ -> throw("whoops") end

    ExBankID.Server.state_change_callback(pid, raise_callback)
    ExBankID.Server.state_change_callback(pid, state_change_callback)
    assert :ok = ExBankID.Server.authenticate(pid, "1.1.1.1")

    # The state change callback will send a message when the server transition from on state to another.
    # If the state goes from :authenticating to :authenticating this means that collect have ben performed.
    assert_receive {:authenticating, :authenticating}, :timer.seconds(3)
  end
end
