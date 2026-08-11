class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :color, null: false, default: "#6c757d"
      t.string :normalized_name, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :tags, :discarded_at
    add_index :tags, :name, unique: true, where: "discarded_at IS NULL",
      name: "index_tags_on_name"
    add_index :tags, :normalized_name, unique: true, where: "discarded_at IS NULL",
      name: "index_tags_on_normalized_name"
  end
end
