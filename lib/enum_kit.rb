# frozen_string_literal: true

require 'enum_kit/constants'
require 'enum_kit/helpers'

if defined?(Rails::Railtie)
  require 'enum_kit/railtie'
else
  raise 'Unable to load EnumKit without Rails.'
end
