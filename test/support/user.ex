defmodule Support.User do
  use Ecto.Schema

  @primary_key {:id, :integer, []}
  schema "users" do
    field :first_name,                :string
    field :last_name,                 :string
    field :favorite_number,           :integer
  end
end
