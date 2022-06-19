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
    success = if amount.positive?
                (self.balance -= amount)
                # Line 23 is the main problem, but there are more insidious
                # problems with validating within `balance=`.
                # Expand to:
                # self.balance = self.balance - amount
                # `self.balance=` prevents updating `@balance`, but the
                # statement returns the rejected value of `self.balance.-(amount)`,
                # thereby initializing `success` to -30. `success` then
                # evaluates as `true` below.
              else
                false
              end

    if success
      "$#{amount} withdrawn. Total balance is $#{balance}."
    else
      "Invalid. Enter positive amount less than or equal to current balance ($#{balance})."
    end
  end

  def balance=(new_balance)
    if valid_transaction?(new_balance)
      @balance = new_balance
      true
    else
      false
    end
  end

  def valid_transaction?(new_balance)
    new_balance >= 0
  end
end

# Example

account = BankAccount.new('5538898', 'Genevieve')

# Expected output:
p account.balance         # => 0
p account.deposit(50)     # => $50 deposited. Total balance is $50.
p account.balance         # => 50
p account.withdraw(80)    # => Expected: Invalid. Enter positive amount less than or equal to current balance ($50).
# Actual: $80 withdrawn. Total balance is $50.
p account.balance         # => 50
