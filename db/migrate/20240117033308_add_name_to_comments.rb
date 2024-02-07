class AddNameToComments < ActiveRecord::Migration[7.0]
  def change
    remove_column :comments, :name
  end
end
