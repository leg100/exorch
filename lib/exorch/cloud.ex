defmodule Exorch.Cloud do
  @callback configure(map) :: map
  @callback get_instances([{atom, atom}], map) :: map
end
