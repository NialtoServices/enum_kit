# EnumKit

EnumKit provides native support for PostgreSQL enums in Ruby on Rails projects.

## Installation

You can install **EnumKit** using the following command:

  $ gem install enum_kit

Or, by adding the following to your `Gemfile`:

```ruby
gem 'enum_kit', '~> 0.1'
```

### Usage

Here's a sample migration file which creates the enum `:shirt_size`, then adds the column `:size` to the `:shirts`
table using the `:shirt_size` enum as the underlying type:

```ruby
class CreateShirts < ActiveRecord::Migration[6.0]
  def change
    create_enum :shirt_size, %i[small medium large]

    create_table :shirts do |t|
      t.string :name
      t.enum   :size, name: :shirt_size

      t.timestamps
    end
  end
end
```

You can remove the enum later using something similar to this:

```ruby
class DropShirts < ActiveRecord::Migration[6.0]
  def change
    drop_table :shirts
    drop_enum  :shirt_size
  end
end
```

Once you've defined an enum in a migration file, you can use it in the associated model:

```ruby
class Shirt < ActiveRecord::Base
  pg_enum :size
end
```

Note that you don't need to define the enum's cases again.
The `pg_enum` method automatically queries the database when Rails boots for the acceptable values!

---

When setting the enum to an unsupported value, an exception is raised. This can be problematic in cases where you don't
have control over the input (such as when using APIs).

To improve this, you can optionally specify that exceptions should not be raised on a per enum basis. Note that when
opting for this feature, you'd ideally specify a validation to capture any unsupported values:

```ruby
class Shirt < ActiveRecord::Base
  pg_enum :size, exceptions: false

  validates :size, pg_enum: true
end
```

The above prevents exceptions from being raised and checks that the assigned value is one of the cases supported by the
enum.

## Development

After checking out the repo, run `bundle exec rake spec` to run the tests.

To install this gem onto your machine, run `bundle exec rake install`.
