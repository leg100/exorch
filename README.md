# Exorch

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exorch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exorch, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exorch](https://hexdocs.pm/exorch).

### design

1 connection; 1 channel

ssh channel (genserver) - exists for life time of channel

send

#### handlers

* filter_instances(args, state) -> [{filter_key, filter_value}]
* ssh_params(args, instance, state)
* run_cmd(args, instance, state) -> cmd_string
* format_output(args, instance, stdout, stderr, exit_code, state) -> map

* handle_call(:filter, from, args) -> {:reply, [{k,v}], args}
* handle_call({:ssh_params, instance}, from, args)
  -> {:reply, ssh_params, {args, instances}}
* handle_call({:cmd, instance}, from, args})
  -> {:reply, cmd_string, {args, instances}}
* handle_call({:format_output, instance}, from, args)
  -> {:reply, output_struct, {args, instances}}

#### CM design

per-instance handlers: called for each instance
global handlers: called once
instance(%{role: "elasticsearch"})
