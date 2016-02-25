# Shows the index of all board lints which are failing
class ChecksController < ApplicationController
  def index
    @checks = Checkers.check_all!
  end
end
