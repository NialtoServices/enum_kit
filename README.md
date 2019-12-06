# EnumKit

[![Build Status](https://travis-ci.org/NialtoServices/enum_kit.svg?branch=master)](https://travis-ci.org/NialtoServices/enum_kit)

EnumKit provides native support for PostgreSQL enums in Ruby on Rails projects.

## Installation

You can install **EnumKit** using the following command:

  $ gem install enum_kit

Or, by adding the following to your `Gemfile`:

```ruby
gem 'enum_kit', '~> 0.3'
```

### Usage

Here is an example migration file that creates an enum called `:shirt_size` and then adds it to the `:shirts` table
using the column name `:size`:

*Pro Tip:* You can omit the `:enum_type` attribute when the name of the enum you want to use exactly matches the name
of the column you're adding.

```ruby
class CreateShirts < ActiveRecord::Migration[6.0]
  def change
    create_enum :shirt_size, %i[small medium large]

    create_table :shirts do |t|
      t.string :name
      t.enum   :size, enum_type: :shirt_size

      t.timestamps
    end
  end
end
```

You can also remove an enum from the database, but you'll need to remove any associated columns first:

```ruby
class DropShirts < ActiveRecord::Migration[6.0]
  def change
    remove_column :shirts, :size
    drop_enum :shirt_size
  end
end
```

Once you've defined an enum, you can use it in the associated model with the `#pg_enum` method:

```ruby
class Shirt < ActiveRecord::Base
  pg_enum :size
end
```

Note that you don't need to define the enum's cases again. The `#pg_enum` method automatically queries the database
once when the model is loaded to determine the supported values.

---

When setting an enum to a value that is not supported, an exception is raised. This can be inconvenient in some cases
such as an API where you can't control what value is submitted.

You can disable the default 'exception raising' behaviour by adding a custom initializer to your Rails project:

```ruby
# Prevent enums from raising exceptions when set to unsupported values.
Rails.application.config.enum_kit.disable_exceptions = true
```

Please note that this will affect *all* enums defined in your Rails app, as the `pg_enum` method simply uses the `enum`
method behind the scenes. There isn't currently an option to set this on a per enum basis.

## Development

After checking out the repo, run `bundle exec rake spec` to run the tests.

To install this gem onto your machine, run `bundle exec rake install`.
