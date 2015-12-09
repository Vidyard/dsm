# Data Synchrotron Migrator

DSM helps make data migrations on large MySQL tables with zero downtime. DSM's interface was modelled after [LHM](https://github.com/soundcloud/lhm). LHM is an essential tool for consistently and easily migrating MySQL schema with zero downtime, however it does not offer any framework for migrating the data within those tables, that is where DSM comes in.

![Protron Synchrotron](http://www.interactions.org/imagebank/images/CE0295M.jpg)

## What DSM provides

- Progress statistics
- Estimate time to completion
- Easy throttling & stride settings
- Uses a reliable and fast method for walking large MySQL tables
- Can specify start and end range for migration (helpful for picking up where you left off)

## Requirements

DSM currently only works with MySQL databases and requires an established ActiveRecord connection and the mysql2 adapter.

## Limitations
Like [LHM](https://github.com/soundcloud/lhm), DSM uses a chunker implementation that relies on the table having a single integer numeric key column called id. DSM performs static sized row copies against the id column. Therefore sparse assignment of id can cause performance problems for the backfills. Typically DSM assumes that id is an auto_increment style column. 

## Installation

`gem install dsm` 
or add `gem "dsm"` to your Gemfile

## Usage

DSM relies on ActiveRecord for its MySQL connection. You setup the ActiveRecord yaml file or setup the ActiveRecord connection manually.

```ruby
require 'dsm'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql2',
  :host => '127.0.0.1',
  :database => 'dsm'
)
connection = ActiveRecord::Base.connection

# and migrate
Dsm.migrate_data :users, :stride => 500, :throttle => 1000 do |begin_range, end_range|
  connection.execute("
    UPDATE users 
    SET first_name = SUBSTRING_INDEX(SUBSTRING_INDEX(name, ' ', 1), ' ', -1) 
    WHERE id BETWEEN #{begin_range} AND #{end_range}")
end
```

To use DSM from an ActiveRecord::Migration in a Rails project, add it to your Gemfile, then invoke as follows:

```ruby
require 'dsm'

class MigrateUsers < ActiveRecord::Migration
  def self.up
    Dsm.migrate_data :users do |begin_range, end_range|
      # do migration SQL within begin_range & end_range
    end
  end

  def self.down
    Dsm.migrate_data :users do |begin_range, end_range|
      # do migration SQL within begin_range & end_range
    end
  end
end
```

## Parameters

| Parameter | Description | Default |
| ------------- | ------------- | ------------- |
| :stride | Number of rows to read before delaying | 1000 rows |
| :throttle | Time in ms to wait between strides | 1000ms |
| :start_id | Id to start the migration from (inclusive) |1 |
| :end_id | Id to end the migration on (inclusive) | MAX(id) |
| :desc | Text description to print out before starting migration | |

## Tests

1. Create a directory name `.dsm` in your home directory
2. Create a file named `dsmrc` that looks like this
```
mysqldir=/usr/local/mysql
dsmdir=~/.dsm/db
port=3308
```

3. cd to dsm project location
4. run `bundle install`
5. run `./bin/dsm-spec-setup.sh` (creates new mysql instance and `dsm` database required for tests)
6. run `bundle exec rspec spec`

## Contributing

1. Fork it
2. Create branch
3. Commit & push changes
4. Create Pull Request back to original fork

## License

DSM is released under the MIT license:
www.opensource.org/licenses/MIT
