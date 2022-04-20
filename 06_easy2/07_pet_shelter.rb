# frozen_string_literal: true

# Imagine an ORM managing this data store.
module ShelterData
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
      @owners = owner_list.map do |owner|
        [owner, { pets: Pets.new }]
      end.to_h
    end

    def add_pet(owner, pet)
      owners[owner][:pets].add(pet)
    end
  end

  class Pets
    attr_reader :data

    def initialize(data = [])
      @data = data
    end

    def add(pet)
      data.push(pet)
    end

    def count
      data.size
    end
  end
end

module ShelterDataFormatters
  class OwnersPets
    def initialize(owners_pets)
      @owners = owners_pets.owners
    end

    def summary(owner)
      "#{owner.name} has #{owners[owner][:pets].count} adopted pets."
    end

    def to_s_detailed
      owners.map do |owner, data|
        pets_formatter = ShelterDataFormatters::Pets.new(data[:pets])

        "#{owner} has adopted the following pets:\n" \
        "#{pets_formatter}"
      end.join("\n\n")
    end

    def to_s
      owners.map do |owner, _|
        summary(owner)
      end.join("\n")
    end

    private

    attr_reader :owners
  end

  class Pets
    def initialize(pets)
      @data = pets.data
    end

    def to_s
      data.map(&:to_s).join("\n")
    end

    private

    attr_reader :data
  end
end

class Shelter
  def initialize(owners_pets, unadopted_pets, formatters: ShelterDataFormatters)
    @owners_pets = owners_pets
    @unadopted_pets = unadopted_pets
    @formatters = formatters
  end

  def adopt(owner, pet)
    owners_pets.add_pet(owner, pet)
  end

  def number_of_unadopted_pets
    unadopted_pets.count
  end

  def adoptions_as_string
    # Imagine: `owners_pets` would filter out owners without pets.
    formatters::OwnersPets.new(owners_pets).to_s_detailed
  end

  def unadopted_pets_as_string
    "The Animal Shelter has the following unadopted pets:\n" \
    "#{formatters::Pets.new(unadopted_pets)}"
  end

  private

  attr_reader :owners_pets, :unadopted_pets, :formatters
end

# Imagine an ORM initializing these items from a DB.

butterscotch = ShelterData::Pet.new('cat', 'Butterscotch')
pudding      = ShelterData::Pet.new('cat', 'Pudding')
darwin       = ShelterData::Pet.new('bearded dragon', 'Darwin')
kennedy      = ShelterData::Pet.new('dog', 'Kennedy')
sweetie      = ShelterData::Pet.new('parakeet', 'Sweetie Pie')
molly        = ShelterData::Pet.new('dog', 'Molly')
chester      = ShelterData::Pet.new('fish', 'Chester')

phanson = ShelterData::Owner.new('P Hanson')
bholmes = ShelterData::Owner.new('B Holmes')

owners_pets = ShelterData::OwnersPets.new([phanson, bholmes])
unadopted_pets = ShelterData::Pets.new(
  [
    ShelterData::Pet.new('dog', 'Asta'),
    ShelterData::Pet.new('dog', 'Laddie'),
    ShelterData::Pet.new('cat', 'Fluffy'),
    ShelterData::Pet.new('cat', 'Kat'),
    ShelterData::Pet.new('cat', 'Ben'),
    ShelterData::Pet.new('parakeet', 'Chatterbox'),
    ShelterData::Pet.new('parakeet', 'Bluebell')
  ]
)

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

owners_pets_formatter = ShelterDataFormatters::OwnersPets.new(owners_pets)

p(owners_pets_formatter.to_s == <<~OUTPUT.strip
  P Hanson has 3 adopted pets.
  B Holmes has 4 adopted pets.
OUTPUT
 )

p(owners_pets_formatter.summary(phanson) == 'P Hanson has 3 adopted pets.')
p(owners_pets_formatter.summary(bholmes) == 'B Holmes has 4 adopted pets.')
p("The Animal Shelter has #{shelter.number_of_unadopted_pets} unadopted pets." == 'The Animal Shelter has 7 unadopted pets.')
