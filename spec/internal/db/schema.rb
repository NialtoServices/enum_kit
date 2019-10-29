# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_enum :shirt_size,  %w[small medium large]

  create_table :shirts do |t|
    t.string :name
    t.enum   :size, name: :shirt_size
  end
end
