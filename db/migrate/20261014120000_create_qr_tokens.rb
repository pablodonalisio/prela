class CreateQrTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :qr_tokens do |t|
      t.string :token, null: false
      t.references :scannable, polymorphic: true, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :qr_tokens, :token, unique: true
    add_index :qr_tokens, :discarded_at
    add_index :qr_tokens, [:scannable_type, :scannable_id],
      unique: true,
      where: "discarded_at IS NULL",
      name: "index_qr_tokens_on_kept_scannable"
  end
end
