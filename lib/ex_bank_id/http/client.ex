defmodule ExBankID.Http.Client do
  @moduledoc """
  The expected behaviour an http client

  You can provide your own http client by creating a module that implements this behaviour.
  Things to consider:
    1. The HTTP method must be POST.
    2. cert_file will be the path to a pem file used to authenticate with the BankID API. Corresponds to [certfile](http://erlang.org/doc/man/ssl.html#TLS/DTLS%20OPTION%20DESCRIPTIONS%20-%20COMMON%20for%20SERVER%20and%20CLIENT)


  The default implementation can be found in ExBankID.Http.Default
  """

  alias ExBankID.Http.Response

  @callback post(
              url :: binary,
              req_body :: binary,
              headers :: [{binary, binary}, ...],
              cert_file :: String.t(),
              http_opts :: term
            ) ::
              {:ok, Response.t()}
              | {:error, %{reason: any}}
end
