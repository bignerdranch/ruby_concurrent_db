class CreateBlobs < ActiveRecord::Migration[5.1]
  def change
    create_table :blobs do |t|
      t.string 'company'
      t.jsonb 'blob'
      t.timestamps
    end
  end
end
