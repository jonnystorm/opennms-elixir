# OpenNMS-Elixir

A tiny Elixir client for the OpenNMS REST API.

## Use

Set `OPENNMS_API_BASEURL`, `OPENNMS_API_USER`, and `OPENNMS_API_PASSWORD`
in your environment.

```bash
> export OPENNMS_API_BASEURL=http://localhost:8980/opennms
> export OPENNMS_API_USER=admin
> export OPENNMS_API_PASSWORD=admin
```

Profit.

## TODO

* Generate client API from OpenNMS documentation.
* Make Ecto adapter?

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `opennms_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [ {:opennms_ex, git: "https://github.com/jonnystorm/opennms-elixir.git"},
  ]
end
```

