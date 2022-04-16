class Pet
  attr_reader :name

  def initialize(name)
    @name = name.to_s
  end

  def to_s
    "My name is #{@name.upcase}."
  end
end

name = 'Fluffy'
fluffy = Pet.new(name)
puts fluffy.name
puts fluffy
puts fluffy.name
puts name

name = 42
fluffy = Pet.new(name)
name += 1
# Line 22 doesn't affect the class state because it's simply reassigning the
# local variable `name` to a new Integer object in memory (`name = name + 1`).
puts fluffy.name
puts fluffy
puts fluffy.name
puts name
