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
    dequeue if array.size == size

    array.push(item)

    self
    # Return the `CircularQueue` instance to align with `Array#push` or similar
    # behavior, which basically appends an item to the internal data structure
    # and then returns `self`.

    # If we weren't aligning with a similar Standard Library data structure
    # class' behavior for some reason, we probably would still return `self`
    # so that this method wouldn't return a pointer to the private `@array`'s
    # assigned array object, which would allow manipulating the internal data,
    # structure.
  end

  def dequeue
    array.shift
  end

  private

  attr_reader :array
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
