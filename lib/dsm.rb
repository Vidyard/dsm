require 'dsm/invoker'

module Dsm
  extend self

  def migrate_data(table, options, &block)
    invoker = Invoker.new(table.to_s, options, connection)
    invoker.run(&block)
  end

  def setup_connection(conn)
    @@connection = conn
  end

  def self.connection
    @@connection ||=
      begin
        raise 'Please call Dsm.setup_connection' unless defined?(ActiveRecord)
        ActiveRecord::Base.connection
      end
    return @@connection
  end
end
