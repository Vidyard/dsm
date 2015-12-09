require 'rspec'
require 'active_support'
require 'active_record'
require 'mysql2'
require File.expand_path('../lib/dsm', File.dirname(__FILE__))

module Dsm
  PORT = 3308

  def connection
    return @connection
  end

  def connect!
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :host     => '127.0.0.1',
      :database => 'dsm',
      :username => 'root',
      :port     => PORT,
      :password => nil
    )
    @connection = ActiveRecord::Base.connection
    ::Dsm.setup_connection(@connection)
  end

  def clean_test_table
    connection.execute("drop table if exists `persons`")
    connection.execute("
      CREATE TABLE `persons` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `data` varchar(10),
        `data2` varchar(10),
        PRIMARY KEY (`id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ")
  end
end
