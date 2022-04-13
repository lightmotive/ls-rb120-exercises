# frozen_string_literal: true

module Transportation
  class Vehicle
  end

  class Truck < Vehicle
  end

  class Car < Vehicle
  end
end

truck1 = Transportation::Truck.new
car1 = Transportation::Car.new
