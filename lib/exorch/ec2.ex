defmodule Exorch.EC2 do
  @behaviour Exorch.Cloud

  alias Exorch.Instance

  def configure(region: region) do
    {:ok, conf} = :erlcloud_aws.profile()
    :erlcloud_aws.service_config(:ec2, region, conf)
  end

  def get_instances(conf, filters) do
    case :erlcloud_ec2.describe_instances([], convert_filters(filters), conf) do
      {:ok, reservations} -> extract_instances(reservations)
    end
  end

  defp extract_instances(reservations) do
    reservations
    |> Enum.reduce([], fn r, acc -> acc ++ r[:instances_set] end)
    |> Enum.map(fn i -> convert_instance(i) end)
  end

  defp convert_instance(erlcloud_instance) do
    %Instance{
      dns_name: List.to_string(erlcloud_instance[:dns_name]),
      key_name: List.to_string(erlcloud_instance[:key_name]),
      image_id: List.to_string(erlcloud_instance[:image_id])
    }
  end

  defp convert_filters(filters) do
    filters |> Enum.map(fn {k,v} -> {to_charlist(k), to_charlist(v)} end)
  end
end
