# frozen_string_literal: true

class Flight
  # Delete: attr_accessor :database_handle
  # The class shouldn't provide public access to `database_handle`.
  # Also, one would probably want to use dependency injection of some kind
  # to inject the Database class, which would simplify unit testing and
  # overall code maintenance.

  def initialize(flight_number)
    @database_handle = Database.init
    @flight_number = flight_number
  end
end
