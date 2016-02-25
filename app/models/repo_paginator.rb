# Retrieves all visible repos in one flat array, handling GitHub pagination
class RepoPaginator < Paginator
  include Enumerable

  def initialize
    super() do |i|
      Github.repos.list(visibility: 'all', page: i)
    end
  end
end
