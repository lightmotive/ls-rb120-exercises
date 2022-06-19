# frozen_string_literal: true

require 'pry'

class Length
  include Comparable

  attr_reader :value, :unit

  def initialize(value, unit)
    @value = value
    @unit = unit
  end

  def as_kilometers
    convert_to(:km, { km: 1, mi: 0.6213711, nmi: 0.539957 })
  end

  def as_miles
    convert_to(:mi, { km: 1.609344, mi: 1, nmi: 0.8689762419 })
  end

  def as_nautical_miles
    convert_to(:nmi, { km: 1.8519993, mi: 1.15078, nmi: 1 })
  end

  def <=>(other)
    return nil if other.class != self.class

    value <=> other.as_unit(unit).value
  end

  def to_s
    "#{value} #{unit}"
  end

  protected

  def as_unit(unit)
    case unit
    when :km then as_kilometers
    when :mi then as_miles
    when :nmi then as_nautical_miles
    end
  end

  private

  def convert_to(target_unit, conversion_factors)
    Length.new((value / conversion_factors[unit]).round(4), target_unit)
  end
end

# Example

puts [Length.new(1, :mi), Length.new(1, :nmi), Length.new(1, :km)].sort
# => comparison of Length with Length failed (ArgumentError)
# expected output:
# 1 km
# 1 mi
# 1 nmi

# Problem: `Array#sort` uses `<=>` to compare each object internally.
# Basic solution: implement `<=>`
# Better solution: include `Comparable`, implement `<=>`, and delete the other
# comparison and equality methods.
