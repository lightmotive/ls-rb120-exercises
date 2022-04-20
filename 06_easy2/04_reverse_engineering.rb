# frozen_string_literal: true

class Transform
  def initialize(string)
    self.string = string.to_s
  end

  def uppercase
    self.class.uppercase(string)
  end

  def lowercase
    self.class.lowercase(string)
  end

  def self.uppercase(string)
    string.upcase
  end

  def self.lowercase(string)
    string.downcase
  end

  private

  attr_accessor :string
end

my_data = Transform.new('abc')
puts my_data.uppercase
puts Transform.lowercase('XYZ')
