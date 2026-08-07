class MigrateLocationEquipmentStatusesToTags < ActiveRecord::Migration[8.0]
  STATUS_MAPPINGS = {
    2 => {name: "PRELA para revisar", normalized_name: "prela para revisar", color: "#0d6efd", new_status: 1},
    3 => {name: "PRELA para entregar", normalized_name: "prela para entregar", color: "#6f42c1", new_status: 1},
    4 => {name: "PRELA en service", normalized_name: "prela en service", color: "#fd7e14", new_status: 1},
    5 => {name: "Inaccesible", normalized_name: "inaccesible", color: "#6c757d", new_status: 0}
  }.freeze

  def up
    STATUS_MAPPINGS.each do |old_status, mapping|
      ensure_tag!(mapping)
      create_taggings_for_status!(old_status, mapping[:normalized_name])
      execute(
        ActiveRecord::Base.sanitize_sql_array([
          "UPDATE location_equipments SET status = ? WHERE status = ?",
          mapping[:new_status],
          old_status
        ])
      )
    end
  end

  def down
    STATUS_MAPPINGS.each do |old_status, mapping|
      execute(
        ActiveRecord::Base.sanitize_sql_array([<<~SQL.squish, old_status, mapping[:normalized_name]])
          UPDATE location_equipments
          SET status = ?
          FROM taggings
          INNER JOIN tags ON tags.id = taggings.tag_id
          WHERE taggings.taggable_type = 'LocationEquipment'
            AND taggings.taggable_id = location_equipments.id
            AND tags.normalized_name = ?
            AND tags.discarded_at IS NULL
        SQL
      )

      execute(
        ActiveRecord::Base.sanitize_sql_array([<<~SQL.squish, mapping[:normalized_name]])
          DELETE FROM taggings
          USING tags
          WHERE taggings.tag_id = tags.id
            AND taggings.taggable_type = 'LocationEquipment'
            AND tags.normalized_name = ?
            AND tags.discarded_at IS NULL
        SQL
      )
    end
  end

  private

  def ensure_tag!(mapping)
    execute(
      ActiveRecord::Base.sanitize_sql_array([
        <<~SQL.squish,
          INSERT INTO tags (name, normalized_name, color, created_at, updated_at)
          SELECT ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          WHERE NOT EXISTS (
            SELECT 1
            FROM tags
            WHERE normalized_name = ?
              AND discarded_at IS NULL
          )
        SQL
        mapping[:name],
        mapping[:normalized_name],
        mapping[:color],
        mapping[:normalized_name]
      ])
    )
  end

  def create_taggings_for_status!(old_status, normalized_name)
    execute(
      ActiveRecord::Base.sanitize_sql_array([
        <<~SQL.squish,
          INSERT INTO taggings (tag_id, taggable_type, taggable_id, created_at, updated_at)
          SELECT tags.id, 'LocationEquipment', location_equipments.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          FROM location_equipments
          INNER JOIN tags
            ON tags.normalized_name = ?
            AND tags.discarded_at IS NULL
          WHERE location_equipments.status = ?
            AND NOT EXISTS (
              SELECT 1
              FROM taggings
              WHERE taggings.tag_id = tags.id
                AND taggings.taggable_type = 'LocationEquipment'
                AND taggings.taggable_id = location_equipments.id
            )
        SQL
        normalized_name,
        old_status
      ])
    )
  end
end
