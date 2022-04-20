# frozen_string_literal: true

class Pet
  def initialize(type, name)
    self.type = type
    self.name = name
  end

  def to_s
    "a #{type} named #{name}"
  end

  private

  attr_accessor :type, :name
end

class Owner
  attr_reader :name, :pets

  def initialize(name)
    @name = name
    @pets = []
  end

  def adopt(pet)
    @pets.push(pet)
  end

  def number_of_pets
    @pets.size
  end

  def pets_as_string_list
    @pets.map(&:to_s)
  end

  def to_s
    name
  end
end

class Shelter
  def initialize
    @owners = {}
  end

  def adopt(owner, pet)
    @owners[owner] = owner
    owner.adopt(pet)
  end

  def adoptions_as_string
    lines = []

    @owners.each do |owner, _|
      lines.push "#{owner} has adopted the following pets:"
      lines.push(*owner.pets_as_string_list)
      lines.push('')
    end

    lines.join("\n").chomp
  end

  def print_adoptions
    puts adoptions_as_string
  end
end

butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)

# shelter.print_adoptions
p(shelter.adoptions_as_string == <<~OUTPUT.strip
  P Hanson has adopted the following pets:
  a cat named Butterscotch
  a cat named Pudding
  a bearded dragon named Darwin

  B Holmes has adopted the following pets:
  a dog named Kennedy
  a parakeet named Sweetie Pie
  a dog named Molly
  a fish named Chester
OUTPUT
 )
p("#{phanson.name} has #{phanson.number_of_pets} adopted pets." == 'P Hanson has 3 adopted pets.')
p("#{bholmes.name} has #{bholmes.number_of_pets} adopted pets." == 'B Holmes has 4 adopted pets.')
