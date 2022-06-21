# frozen_string_literal: true

# Circular queue:
# `enqueue(item)`:
# - If queue is already full, first remove the first item (oldest).
# - Add item to the end of the queue.
# `dequeue`
# - If no items, return nil.
# - Otherwise, remove and return first item.

class CircularQueue
  attr_reader :size

  def initialize(size)
    @size = size
    @array = []
  end

  def enqueue(item)
    array.shift if array.size == size

    array.push(item)

    self
  end

  def dequeue
    return nil if array.empty?

    array.shift
  end

  private

  attr_accessor :array
end

queue = CircularQueue.new(3)
puts queue.dequeue.nil?

queue.enqueue(1)
queue.enqueue(2)
puts queue.dequeue == 1

queue.enqueue(3)
queue.enqueue(4)
puts queue.dequeue == 2

queue.enqueue(5)
queue.enqueue(6)
queue.enqueue(7)
puts queue.dequeue == 5
puts queue.dequeue == 6
puts queue.dequeue == 7
puts queue.dequeue.nil?

queue = CircularQueue.new(4)
puts queue.dequeue.nil?

queue.enqueue(1)
queue.enqueue(2)
puts queue.dequeue == 1

queue.enqueue(3)
queue.enqueue(4)
puts queue.dequeue == 2

queue.enqueue(5)
queue.enqueue(6)
queue.enqueue(7)
puts queue.dequeue == 4
puts queue.dequeue == 5
puts queue.dequeue == 6
puts queue.dequeue == 7
puts queue.dequeue.nil?
