class AddConstraintsToMentions < ActiveRecord::Migration[7.0]
  def change
    change_column :reports, :content, :string, null: false, default: ''
  end
end
