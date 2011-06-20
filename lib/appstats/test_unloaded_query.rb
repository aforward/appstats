
# Do not explicitly load this file - it will be done in a test
class UnloadedQuery
  attr_accessor :query
  def process_query; end
  def db_connection
    ActiveRecord::Base.connection
  end
end