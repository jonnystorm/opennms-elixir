# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule OpenNMS do
  @moduledoc """
  A tiny Elixir client for the OpenNMS REST API.
  """

  use Tesla, only: []

  adapter Tesla.Adapter.Hackney

  defp get_api_base_url do
    System.get_env("OPENNMS_API_BASEURL")
    || Application.get_env(:opennms_ex, :api_base_url)
  end

  defp get_api_user do
    System.get_env("OPENNMS_API_USER")
    || Application.get_env(:opennms_ex, :api_user)
  end

  defp get_api_password do
    System.get_env("OPENNMS_API_PASSWORD")
    || Application.get_env(:opennms_ex, :api_password)
  end

  defp client do
    user = get_api_user()
    password = get_api_password()

    Tesla.build_client [
      {Tesla.Middleware.BaseUrl, get_api_base_url()},
      {Tesla.Middleware.Headers, %{"Accept" => "application/json"}},
      {Tesla.Middleware.BasicAuth, %{username: user, password: password}},
      {Tesla.Middleware.DecodeJson, nil},
      {OpenNMS.Middleware.SetEncodingByMethod, nil},
    ]
  end

  defp send_request(method, url, query) when method in [:get, :delete] do
    url =
      url
      |> URI.encode
      |> Tesla.build_url(query)

    request(client(), [method: method, url: url])
  end

  defp send_request(method, url, body) when method in [:put] do
    url = URI.encode url

    request(client(), [method: method, url: url, body: body])
  end

  defp    get(url, query \\ []), do: send_request(:get,    url, query)
  defp delete(url, query \\ []), do: send_request(:delete, url, query)

  defp  put(url, body), do: send_request(:put,  url, body)


  ### Public API ###

  @doc """
  Get all active requisitions.
  """
  def requisitions,
    do: get "/rest/requisitions"

  @doc """
  Get the active requisition for the given foreign-source name.
  """
  def requisition(name),
    do: get "/rest/requisitions/#{name}"

  @doc """
  Get the list of nodes being requisitioned for the given foreign-source name.
  """
  def requisition_nodes(name),
    do: get "/rest/requisitions/#{name}/nodes"

  @doc """
  Get the node with the given foreign ID for the given foreign source name.
  """
  def requisition_node(name, foreign_id),
    do: get "/rest/requisitions/#{name}/nodes/#{foreign_id}"

  @doc """
  Update the specified node for the given foreign source.
  """
  def update_requisition_node(key_value_pairs, name, foreign_id),
    do: put "/rest/requisitions/#{name}/nodes/#{foreign_id}", key_value_pairs
end

defmodule OpenNMS.Middleware.SetEncodingByMethod do
  defp get_codec_by_method(method) do
    case method do
      :put -> Tesla.Middleware.FormUrlencoded
      #:post -> OpenNMS.Middleware.XML
      _ -> Tesla.Middleware.JSON
    end
  end

  def call(env, next, opts) do
    opts = opts || []

    env
    |> get_codec_by_method(env.method).encode(opts)
    |> Tesla.run(next)
  end
end
