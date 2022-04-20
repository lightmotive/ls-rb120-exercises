# frozen_string_literal: true

module Walkable
  def display_name
    name
  end

  def walk
    "#{display_name} #{gait} forward"
  end
end

class Person
  include Walkable

  attr_reader :name

  def initialize(name)
    @name = name
  end

  private

  def gait
    'strolls'
  end
end

class Nobility < Person
  include Walkable

  attr_reader :title

  def initialize(name, title)
    super(name)
    @title = title
  end

  def display_name
    "#{title} #{name}"
  end

  def gait
    'struts'
  end
end

class Cat
  include Walkable

  attr_reader :name

  def initialize(name)
    @name = name
  end

  private

  def gait
    'saunters'
  end
end

class Cheetah
  include Walkable

  attr_reader :name

  def initialize(name)
    @name = name
  end

  private

  def gait
    'runs'
  end
end

mike = Person.new('Mike')
p mike.walk == 'Mike strolls forward'

byron = Nobility.new('Byron', 'Lord')
p byron.walk == 'Lord Byron struts forward'

kitty = Cat.new('Kitty')
p kitty.walk == 'Kitty saunters forward'

flash = Cheetah.new('Flash')
p flash.walk == 'Flash runs forward'
