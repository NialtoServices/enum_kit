# frozen_string_literal: true

class Shirt < ActiveRecord::Base
  pg_enum :size, exceptions: false

  validates :size, pg_enum: true
end
