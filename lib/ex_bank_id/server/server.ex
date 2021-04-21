defmodule ExBankID.Server do
  @updatable_states [:authenticating, :signing]
  @update_interval :timer.seconds(2)

  @behaviour :gen_statem

  def start_link(bank_id_opts \\ [], start_opts \\ []) do
    :gen_statem.start_link(__MODULE__, bank_id_opts, start_opts)
  end

  def callback_mode() do
    [:handle_event_function, :state_enter]
  end

  def init(opts) do
    {:ok, :ready,
     %{bank_id_opts: opts, bank_id_data: %{init_resp: nil, collect: nil}, change_callback: []}}
  end

  def state(pid) when is_pid(pid) do
    :gen_statem.call(pid, {:get, fn state, _data -> state end})
  end

  def data(pid) when is_pid(pid) do
    :gen_statem.call(pid, {:get, fn _state, data -> data end})
  end

  def authenticate(pid, ip) when is_pid(pid) do
    :gen_statem.call(pid, {:auth, ip})
  end

  def state_change_callback(pid, fun) when is_function(fun, 3) and is_pid(pid) do
    :gen_statem.cast(pid, {:put_change_callback, fun})
  end

  def state_change_callback(pid, fun) when is_list(fun) and is_pid(pid) do
    :gen_statem.cast(pid, {:put_change_callback, fun})
  end

  def handle_event(:cast, {:put_change_callback, fun}, _state, data) when is_function(fun, 3) do
    {:keep_state, %{data | change_callback: [fun | data.change_callback]}}
  end

  def handle_event(:cast, {:put_change_callback, fun}, _state, data) when is_list(fun) do
    {:keep_state, %{data | change_callback: fun ++ data.change_callback}}
  end

  def handle_event({:call, from}, {:get, fun}, state, %{bank_id_data: data})
      when is_function(fun, 2) do
    {:keep_state_and_data, [{:reply, from, fun.(state, data)}]}
  end

  def handle_event({:call, from}, {:auth, {ip, pnr}}, :ready, data) do
    opts = Keyword.merge(data.bank_id_opts, personal_number: pnr)
    do_auth(ip, opts, data, from)
  end

  def handle_event({:call, from}, {:auth, ip}, :ready, data) do
    do_auth(ip, data.bank_id_opts, data, from)
  end

  def handle_event(
        :state_timeout,
        :update,
        state,
        %{
          bank_id_opts: opts,
          bank_id_data: %{init_resp: %{orderRef: ref}}
        } = old_data
      )
      when state in @updatable_states do
    case ExBankID.collect(ref, opts) do
      {:ok, %ExBankID.Collect.Response{status: "pending"} = data} ->
        {:repeat_state, %{old_data | bank_id_data: data},
         [{:state_timeout, @update_interval, :update}]}

      {:ok, %ExBankID.Collect.Response{status: "complete"} = data} ->
        {:next_state, :complete, %{old_data | bank_id_data: data}}

      {:ok, %ExBankID.Collect.Response{status: "failed"} = data} ->
        {:next_state, :failed, %{old_data | bank_id_data: data}}

      {:error, reason} ->
        {:next_state, :failed, %{old_data | bank_id_data: reason}}
    end
  end

  def handle_event(:enter, old_state, state, %{change_callback: funs, bank_id_data: data}) do
    try do
      for f <- funs, do: do_change_callback(f, old_state, state, data)
    catch
      _ -> nil
    end

    {:keep_state_and_data, []}
  end

  def handle_event(:enter, _old_state, _state, %{change_callback: []}) do
    {:keep_state_and_data, []}
  end

  defp do_auth(ip, opts, data, from) do
    case ExBankID.auth(ip, opts) do
      {:ok, auth} ->
        {:next_state, :authenticating,
         %{data | bank_id_data: %{data.bank_id_data | init_resp: auth}},
         [{:reply, from, :ok}, {:state_timeout, @update_interval, :update}]}

      {:error, reason} ->
        {:keep_state_and_data, [{:reply, from, {:error, reason}}]}
    end
  end

  defp do_change_callback(fun, old_state, state, data) do
    try do
      fun.(old_state, state, data)
    rescue
      _ -> nil
    end
  end
end
