class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :description
      t.references :documentable, null: false, polymorphic: true

      t.timestamps
    end
  end
end
