# frozen_string_literal: true

# Imagine an ORM managing this data store.
module ShelterORM
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
    attr_reader :name

    def initialize(name)
      @name = name
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

  class OwnersPets
    attr_reader :owners

    def initialize(owner_list)
      self.owners = owner_list.map do |owner|
        [owner, { pets: Pets.new }]
      end.to_h
    end

    def add_pet(owner, pet)
      owners[owner][:pets].add(pet)
    end

    def owner_summary(owner)
      "#{owner.name} has #{owners[owner][:pets].count} adopted pets."
    end

    def to_s_detailed
      owners.map do |owner, data|
        "#{owner} has adopted the following pets:\n" \
        "#{data[:pets]}"
      end.join("\n\n")
    end

    def to_s
      owners.map do |owner, _|
        owner_summary(owner)
      end.join("\n")
    end

    private

    attr_writer :owners
  end

  class Pets
    def initialize(data = [])
      self.data = data
    end

    def add(pet)
      data.push(pet)
    end

    def count
      data.size
    end

    def to_s
      data.map(&:to_s).join("\n")
    end

    private

    attr_accessor :data
  end
end

class Shelter
  def initialize(owners_pets, unadopted_pets)
    @owners_pets = owners_pets
    @unadopted_pets = unadopted_pets
  end

  def adopt(owner, pet)
    owners_pets.add_pet(owner, pet)
  end

  def number_of_unadopted_pets
    unadopted_pets.count
  end

  def adoptions_as_string
    # Imagine: `owners_pets` would first filter by owner with pets.
    owners_pets.to_s_detailed
  end

  def unadopted_pets_as_string
    "The Animal Shelter has the following unadopted pets:\n" \
    "#{unadopted_pets}"
  end

  private

  attr_reader :owners_pets, :unadopted_pets
end

butterscotch = ShelterORM::Pet.new('cat', 'Butterscotch')
pudding      = ShelterORM::Pet.new('cat', 'Pudding')
darwin       = ShelterORM::Pet.new('bearded dragon', 'Darwin')
kennedy      = ShelterORM::Pet.new('dog', 'Kennedy')
sweetie      = ShelterORM::Pet.new('parakeet', 'Sweetie Pie')
molly        = ShelterORM::Pet.new('dog', 'Molly')
chester      = ShelterORM::Pet.new('fish', 'Chester')

phanson = ShelterORM::Owner.new('P Hanson')
bholmes = ShelterORM::Owner.new('B Holmes')

owners_pets = ShelterORM::OwnersPets.new([phanson, bholmes])
unadopted_pets = ShelterORM::Pets.new(
  [
    ShelterORM::Pet.new('dog', 'Asta'),
    ShelterORM::Pet.new('dog', 'Laddie'),
    ShelterORM::Pet.new('cat', 'Fluffy'),
    ShelterORM::Pet.new('cat', 'Kat'),
    ShelterORM::Pet.new('cat', 'Ben'),
    ShelterORM::Pet.new('parakeet', 'Chatterbox'),
    ShelterORM::Pet.new('parakeet', 'Bluebell')
  ]
)

# Imagine an ORM initialized those data stores and pulled data from a DB.

shelter = Shelter.new(owners_pets, unadopted_pets)
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)

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

p(owners_pets.to_s == <<~OUTPUT.strip
  P Hanson has 3 adopted pets.
  B Holmes has 4 adopted pets.
OUTPUT
 )

p(owners_pets.owner_summary(phanson) == 'P Hanson has 3 adopted pets.')
p(owners_pets.owner_summary(bholmes) == 'B Holmes has 4 adopted pets.')
p("The Animal Shelter has #{shelter.number_of_unadopted_pets} unadopted pets." == 'The Animal Shelter has 7 unadopted pets.')
