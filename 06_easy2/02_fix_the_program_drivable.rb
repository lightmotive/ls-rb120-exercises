# frozen_string_literal: true

module Drivable
  def drive
    # ...
  end
end

class Car
  include Drivable
end

bobs_car = Car.new
bobs_car.drive
