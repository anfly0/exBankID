defmodule ExBankID.PayloadHelpers do
  @moduledoc """
  Checkers for Payload options

  https://www.bankid.com/assets/bankid/rp/bankid-relying-party-guidelines-v3.4.pdf
  """

  @doc """
  Returns {:ok, ip_addres} or {:error, reason} for IP address validity

  ## Examples
      iex> ExBankID.PayloadHelpers.check_ip_address("1.1.1.1")
      {:ok, "1.1.1.1"}

      iex> ExBankID.PayloadHelpers.check_ip_address("345.0.0.0")
      {:error, "Invalid ip address: 345.0.0.0"}
  """
  def check_ip_address(ip_address)
       when is_binary(ip_address) do
    ip_address_cl = String.to_charlist(ip_address)

    case :inet.parse_strict_address(ip_address_cl) do
      {:ok, _} ->
        {:ok, ip_address}

      _ ->
        {:error, "Invalid ip address: #{ip_address}"}
    end
  end

  @doc """
  Returns {:ok, personal_number} or {:error, reason} for personal number

  ## Examples
      iex> ExBankID.PayloadHelpers.check_personal_number("190000000000")
      {:ok, "190000000000"}

      iex> ExBankID.PayloadHelpers.check_personal_number("42")
      {:error, "Invalid personal number: 42"}
  """
  def check_personal_number(personal_number)
       when is_binary(personal_number) do
    # TODO: Implement relevant personal number check.
    case String.length(personal_number) do
      12 ->
        {:ok, personal_number}

      _ ->
        {:error, "Invalid personal number: #{personal_number}"}
    end
  end

  @doc """
  Returns {:ok, nil} when personal number is omitted

  ## Examples
      iex> ExBankID.PayloadHelpers.check_personal_number(nil)
      {:ok, nil}
  """
  def check_personal_number(nil) do
    {:ok, nil}
  end

  @doc """
  Returns {:ok, nil} when requirement is omitted

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(nil)
      {:ok, nil}
  """
  def check_requirement(nil), do: {:ok, nil}

  @doc """
  Returns {:ok, requirement} when all requirement's keys are valid

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(%{allowFingerprint: :true, cardReader: "class1"})
      {:ok, %{allowFingerprint: :true, cardReader: "class1"}}

      iex> ExBankID.PayloadHelpers.check_requirement(%{tokenStartRequired: :false, notRealRequirement: "fails"})
      {:error, "Invalid requirement"}
  """
  def check_requirement(%{} = requirement) do
    if Enum.all?(
         Enum.map(
           Map.keys(requirement),
           fn key -> check_requirement(key, requirement[key]) end
         ),
         fn result -> result == {:ok, nil} end
       ) do
      {:ok, requirement}
    else
      {:error, "Invalid requirement"}
    end
  end

  @doc """
  Returns {:ok, nil} when requirement is anything besides a map or nil

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement("something")
      {:error, "Invalid requirement"}
  """
  def check_requirement(_), do: {:error, "Invalid requirement"}

  def check_requirement(:allowFingerprint, value) when is_boolean(value), do: {:ok, nil}

  @deprecated "Will not be possible to use in future versions of the RP API. Use tokenStartRequired."
  @doc """
  Returns {:ok, nil} when autoStartTokenRequired is a boolean

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:autoStartTokenRequired, :false)
      {:ok, nil}

      iex> ExBankID.PayloadHelpers.check_requirement(:autoStartTokenRequired, "true")
      {:error, "Invalid requirement"}
  """
  def check_requirement(:autoStartTokenRequired, value) when is_boolean(value), do: {:ok, nil}

  @doc """
  Returns {:ok, nil} when cardReader is "class1" or "class2"

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:cardReader, "class1")
      {:ok, nil}

      iex> ExBankID.PayloadHelpers.check_requirement(:cardReader, "class3")
      {:error, "Invalid requirement"}
  """
  def check_requirement(:cardReader, value) when is_binary(value) do
    case value do
      "class1" -> {:ok, nil}
      "class2" -> {:ok, nil}
      _ -> {:error, "Invalid requirement"}
    end
  end

  @doc """
  Returns {:error, "Invalid requirement"} when certificatePolicies is an empty list

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:certificatePolicies, [])
      {:error, "Invalid requirement"}
  """
  def check_requirement(:certificatePolicies, []), do: {:error, "Invalid requirement"}

  @doc """
  Returns {:ok, nil} when certificatePolicies is a list of oid's

  One wildcard "*" is allowed from position 5 and forward ie. 1.2.752.78.*

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:certificatePolicies, ["1.2.752.78.*", "1.2.752.78.1.5"])
      {:ok, nil}

      iex> ExBankID.PayloadHelpers.check_requirement(:certificatePolicies, ["not an oid"])
      {:error, "Invalid requirement"}
  """
  def check_requirement(:certificatePolicies, value) when is_list(value) do
    if Enum.all?(value, fn oid -> oid?(oid) end) do
      {:ok, nil}
    else
      {:error, "Invalid requirement"}
    end
  end

  @doc """
  Returns {:error, "Invalid requirement"} when issuerCn is an empty list

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:certificatePolicies, [])
      {:error, "Invalid requirement"}
  """
  def check_requirement(:issuerCn, []), do: {:error, "Invalid requirement"}

  @doc """
  Returns {:ok, nil} when issuerCn is a list of strings

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:issuerCn, ["Nordea CA for Smartcard users 12", "Nordea Test CA for Softcert users 13"])
      {:ok, nil}

      iex> ExBankID.PayloadHelpers.check_requirement(:issuerCn, "Nordea Test CA for Softcert users 13")
      {:error, "Invalid requirement"}
  """
  def check_requirement(:issuerCn, value) when is_list(value) do
    if Enum.all?(value, fn cn -> is_binary(cn) end) do
      {:ok, nil}
    else
      {:error, "Invalid requirement"}
    end
  end

  @doc """
  Returns {:ok, nil} when tokenStartRequired is a boolean

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:tokenStartRequired, :false)
      {:ok, nil}

      iex> ExBankID.PayloadHelpers.check_requirement(:tokenStartRequired, "true")
      {:error, "Invalid requirement"}
  """
  def check_requirement(:tokenStartRequired, value) when is_boolean(value), do: {:ok, nil}

  @doc """
  Returns {:error, "Invalid requirement"} when key, value is anything else besides above permitted

  ## Examples
      iex> ExBankID.PayloadHelpers.check_requirement(:foo, "bar")
      {:error, "Invalid requirement"}
  """
  def check_requirement(_, _), do: {:error, "Invalid requirement"}

  @doc """
  Returns true when value is an oid

  One wildcard "*" is allowed from position 5 and forward ie. 1.2.752.78.*

  ## Examples
      iex> ExBankID.PayloadHelpers.oid?("1.2.752.78.*")
      true

      iex> ExBankID.PayloadHelpers.oid?("1.2.3.4.5.6.7.8.9.10.11.13")
      true

      iex> ExBankID.PayloadHelpers.oid?("1.2.3.4.5.6.7.8.9.10.11.13.14")
      false

      iex> ExBankID.PayloadHelpers.oid?("1.2.3.4.5")
      true

      iex> ExBankID.PayloadHelpers.oid?("1.2.3.4.*")
      true

      iex> ExBankID.PayloadHelpers.oid?("1.2.3.*")
      false
  """
  def oid?(value) when is_binary(value) do
    value =~ ~r/^([1-9][0-9]{0,3}|0)(\.([1-9][0-9]{0,3}|0)){5,13}$/ or
      value =~ ~r/^([1-9][0-9]{0,3}|0)(\.([1-9][0-9]{0,3}|0)){3}(\.([1-9][0-9]{0,3}|0|\*)){0,9}$/
  end

  @doc """
  Returns false when arg is anything other than a string

  ## Examples
      iex> ExBankID.PayloadHelpers.oid?(:foo)
      false
  """
  def oid?(_), do: false
end
