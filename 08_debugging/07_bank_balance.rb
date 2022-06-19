# frozen_string_literal: true

class BankAccount
  attr_reader :balance

  def initialize(account_number, client)
    @account_number = account_number
    @client = client
    @balance = 0
  end

  def deposit(amount)
    if amount.positive?
      self.balance += amount
      "$#{amount} deposited. Total balance is $#{balance}."
    else
      'Invalid. Enter a positive amount.'
    end
  end

  def withdraw(amount)
    unless withdraw_amount_valid?(amount)
      return "Invalid. Enter positive amount less than or equal to current balance ($#{balance})."
    end

    self.balance -= amount

    "$#{amount} withdrawn. Total balance is $#{balance}."
  end

  def withdraw_amount_valid?(amount)
    return false if amount.negative?

    (balance - amount) >= 0
  end

  private

  attr_writer :balance
end

# Example

account = BankAccount.new('5538898', 'Genevieve')

# Expected output:
p account.balance         # => 0
p account.deposit(50)     # => $50 deposited. Total balance is $50.
p account.balance         # => 50
p account.withdraw(80)    # => Expected: Invalid. Enter positive amount less than or equal to current balance ($50).
p account.balance         # => 50
p account.withdraw(30)    # => $30 withdrawn. Total balance is $20.
p account.balance         # => 20
