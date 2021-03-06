# frozen_string_literal: true

class Library
  attr_accessor :address, :phone

  def initialize(address, phone)
    @address = address
    @phone = phone
    @books = []
  end

  def check_in(book)
    books.push(book)
  end

  def display_books
    books.each(&:display_data)
  end

  private

  attr_reader :books
end

class Book
  attr_accessor :title, :author, :isbn

  def initialize(title, author, isbn)
    @title = title
    @author = author
    @isbn = isbn
  end

  def display_data
    puts '---------------'
    puts "Title: #{title}"
    puts "Author: #{author}"
    puts "ISBN: #{isbn}"
    puts '---------------'
  end
end

community_library = Library.new('123 Main St.', '555-232-5652')
learn_to_program = Book.new('Learn to Program', 'Chris Pine', '978-1934356364')
little_women = Book.new('Little Women', 'Louisa May Alcott', '978-1420951080')
wrinkle_in_time = Book.new('A Wrinkle in Time', 'Madeleine L\'Engle', '978-0312367541')

community_library.check_in(learn_to_program)
community_library.check_in(little_women)
community_library.check_in(wrinkle_in_time)

# community_library.books.display_data
# Problem with line 44: `books` is an array, which doesn't have a `display_data`
# method. The intention: display data for each `book` object in `books`.
# Quick solution:
# community_library.books.each(&:display_data)
# That behavior should be encapsulated in `Library`:
community_library.display_books
# NOTE: the `books` attribute is now private so `Library` can protect the data.
