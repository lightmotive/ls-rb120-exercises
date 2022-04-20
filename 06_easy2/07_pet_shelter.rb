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

  def add_pet(pet)
    @pets.push(pet)
  end

  def number_of_pets
    @pets.size
  end

  def to_s
    name
  end

  def ==(other)
    name == other.name
  end

  alias eql? ==

  def hash
    name.hash
  end
end

class Shelter
  def initialize
    @owners = {}
    @unadopted_pets = [
      Pet.new('dog', 'Asta'),
      Pet.new('dog', 'Laddie'),
      Pet.new('cat', 'Fluffy'),
      Pet.new('cat', 'Kat'),
      Pet.new('cat', 'Ben'),
      Pet.new('parakeet', 'Chatterbox'),
      Pet.new('parakeet', 'Bluebell')
    ]
    # Imagine those are retrieved from data stores and are loaded into entity
    # classes.
  end

  def adopt(owner, pet)
    @owners[owner] ||= owner
    owner.add_pet(pet)
  end

  def adoptions_as_string
    lines = []

    @owners.each do |owner, _|
      lines.push "#{owner} has adopted the following pets:"
      lines.push(*owner.pets.map(&:to_s))
      lines.push('')
    end

    lines.join("\n").chomp
  end

  def print_adoptions
    puts adoptions_as_string
  end

  def number_of_unadopted_pets
    @unadopted_pets.size
  end

  def unadopted_pets_as_string
    lines = []

    lines.push 'The Animal Shelter has the following unadopted pets:'
    lines.push(*@unadopted_pets.map(&:to_s))

    lines.join("\n")
  end

  def print_unadopted_pets
    puts unadopted_pets_as_string
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

# shelter.print_unadopted_pets
p(shelter.unadopted_pets_as_string == <<~OUTPUT.strip
  The Animal Shelter has the following unadopted pets:
  a dog named Asta
  a dog named Laddie
  a cat named Fluffy
  a cat named Kat
  a cat named Ben
  a parakeet named Chatterbox
  a parakeet named Bluebell
OUTPUT
 )
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
p("The Animal Shelter has #{shelter.number_of_unadopted_pets} unadopted pets." == 'The Animal Shelter has 7 unadopted pets.')
