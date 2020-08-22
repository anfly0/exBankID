# exBankID
![license: MIT](https://img.shields.io/github/license/anfly0/exBankID)
![test](https://img.shields.io/github/workflow/status/anfly0/exbankid/Elixir%20CI/master)
[![Coverage Status](https://coveralls.io/repos/github/anfly0/exBankID/badge.svg?branch=master)](https://coveralls.io/github/anfly0/exBankID?branch=master)
![hex version](https://img.shields.io/hexpm/v/exbankid)
## Introduction
ExBankID is a simple stateless elixir client for the [Swedish BankID API](https://www.bankid.com/).

## Installation
This library is available as a package on [hex.pm](https://hex.pm/packages/exBankID) and can be installed by
adding ```{:ex_bank_id, "~> 0.1.1", hex: :exBankID}``` to your list of dependencies in ```mix.exs```.
### Optional dependencies:
```elixir
{:poison, "~> 3.1"} # Add this to your deps if you want to use the default json handler
```

## Configuration
```elixir
# config/config.exs

config :ex_bank_id,
  # Using a custom http client. Should be a module that implements ExBankID.Http.Client.
  # Defaults to ExBankID.Http.Default
  http_client: MyApp.Http.Client

  # Using a custom json handler. Should be a module that implements ExBankID.Json.Handler.
  # Defaults to ExBankID.Json.Default
  json_handler: MyApp.Json.Handler

  # The path to the client cert file used to authenticate with the BankID API
  # Defaults to the test cert in the assets directory.
  cert_file: "/path/to/cert/file.pem"

  # BankID API url
  # Defaults to "https://appapi2.test.bankid.com/rp/v5.1/"
  url: "https://appapi2.bankid.com/rp/<api version 5 or 5.1>/"

```
All the above configuration options can be overridden by setting the new value for the corresponding key in the opts Keyword list passed to any of the functions in ExBankID.

__Example:__
```elixir
# This will override the url in the config.
ExBankID.auth("1.1.1.1", url: "my.mock-server.local")

# This will override the configured/default json handler and url
ExBankID.auth("1.1.1.1", json_handler: Custom.Json.Handler, url: "my.mock-server.local")
```


## Basic usage

```elixir

# Authenticate with ip address and optionally the personal number (12 digits)
iex> {:ok, authentication} = ExBankID.auth("1.1.1.1", personal_number: "190000000000")
{:ok,
 %ExBankID.Auth.Response{
   autoStartToken: "3241031e-d849-4e3a-a662-1a36e65eff93",
   orderRef: "9b69419c-b3ac-4f7c-9796-bf54f1a4e40b",
   qrStartSecret: "c0846df5-f96d-49c0-9ef5-4126cd9376e9",
   qrStartToken: "3fb97679-98cb-42da-afe6-62aecbaaab7e"
 }}

# Collect the status of the initiated authentication either with the orderRef
# or with the ExBankID.Auth.Response struct
iex> {:ok, collect_response} = ExBankID.collect("9b69419c-b3ac-4f7c-9796-bf54f1a4e40b")
{:ok,
 %ExBankID.Collect.Response{
   completionData: %ExBankID.Collect.CompletionData{
     cert: %{},
     device: %{},
     ocspResponse: nil,
     signature: nil,
     user: %ExBankID.Collect.User{
       givenName: nil,
       name: nil,
       personalNumber: nil,
       surname: nil
     }
   },
   hintCode: "outstandingTransaction",
   orderRef: "1fadf49f-c695-4bb3-869a-61aee9678009",
   status: "pending"
 }}

 # Using ExBankID.Auth.Response struct
 iex> {:ok, collect_response} = ExBankID.collect(authentication)
{:ok,
 %ExBankID.Collect.Response{
   completionData: %ExBankID.Collect.CompletionData{
     cert: %{},
     device: %{},
     ocspResponse: nil,
     signature: nil,
     user: %ExBankID.Collect.User{
       givenName: nil,
       name: nil,
       personalNumber: nil,
       surname: nil
     }
   },
   hintCode: "outstandingTransaction",
   orderRef: "1fadf49f-c695-4bb3-869a-61aee9678009",
   status: "pending"
 }}

 # When authentication is completed by the end user the fields in CompletionData will
 # be populated.

 #User signing a given message.
 iex> {:ok, sign} = ExBankID.sign(
                "1.1.1.1",
                "This will be displayed in the BankID app",
                personal_number: "190000000000",    # Optional
                user_non_visible_data: "Not displayed" # Optional
                )
{:ok,
 %ExBankID.Sign.Response{
   autoStartToken: "c7b67410-c376-4d27-9aff-f7e331082619",
   orderRef: "90b3816d-c1d3-4650-aa4d-26d9996160de",
   qrStartSecret: "f28787ec-a554-4db4-90c6-dd662dd249bc",
   qrStartToken: "c7a2373b-9a7a-470f-816f-0af0c3d82053"
 }}
# Collecting is done the same way as for a authentication.

# Canceling a sign or authentication
iex> {:ok, _} = ExBankID.cancel(authentication)
{:ok, %{}}



```