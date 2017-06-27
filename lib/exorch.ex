defmodule Exorch do

  alias Exorch.EC2
  alias Exorch.SSHConnection
  alias Exorch.Response

  def main(argv) do
    {conf, filters} = configure_cloud(argv)
    instances = filter_instances(conf, filters)
    Enum.map(instances, fn i ->
      Task.async(fn ->
        conn = set_ssh_connection_params(argv, i, conf)
        resp =
          with {:ok, ref} <- SSHConnection.connect(conn) do
            SSHConnection.run(ref, set_cmd(argv))
            |> Response.create(i)
          end

        format_output(resp) |> print_output(resp)

        Response.success?(resp)
      end)
    end)
    |> Enum.map(fn pid ->
      Task.await(pid)
    end)
    |> Enum.all?()
    |> (fn true  -> System.halt(0)
           false -> System.halt(1)
    end).()
  end

  defp format_output(resp) do
    Response.format_output(resp)
  end

  defp print_output(output, resp) do
    case Response.success?(resp) do
      true -> IO.puts(:stdio, output)
      false -> IO.puts(:stderr, output)
    end
  end

  def configure_cloud(argv) do
    {EC2.configure(region: "eu-west-1"), set_filters(argv)}
  end

  def set_filters(argv) do
    argv
    |> Enum.take(length(argv) - 1)
    |> Enum.map(fn a -> String.split(a, "=") end)
    |> Enum.map(fn [k,v] -> {k,v} end)
  end

  def set_cmd(argv), do: List.last(argv)

  def filter_instances(conf, filters) do
    EC2.get_instances(conf, filters)
  end

  def set_state(_argv, _instances, _conf) do
  end

  def set_ssh_connection_params(_argv, instance, conf) do
    %SSHConnection{
      user: ami_default_user(instance.image_id, conf),
      identity_file: use_key_name(instance.key_name),
      host: instance.dns_name
    }
  end

  defp use_key_name(key_name) do
    Path.join(~w(#{System.user_home} .ssh #{key_name}.pem))
  end

  defp ami_default_user(image_id, conf) do
    {:ok, images} = :erlcloud_ec2.describe_images([image_id], conf)

    case List.first(images)[:name] do
      'amzn-ami-hvm-2017.03.0.20170417-x86_64-gp2' -> "ec2-user"
      'ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20170619.1' ->
        "ubuntu"
    end
  end
end
