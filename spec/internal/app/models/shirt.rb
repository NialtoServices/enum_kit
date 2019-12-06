# frozen_string_literal: true

class Shirt < ActiveRecord::Base
  pg_enum :size

  validates :size, pg_enum: true
end
