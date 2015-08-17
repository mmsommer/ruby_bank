class Account
  attr_reader :number, :balance, :audit_log

  def initialize(number)
    @number = number
    @balance = 0
    @audit_log = Array.new
    add_log "Account #{@number} created with a balance of #{@balance}."
  end

  def deposit(amount)
    @balance += amount

    add_log "Deposited #{amount}"
  end

  def withdraw(amount)
    @balance -= amount

    add_log "Withdraw #{amount}"
  end

  def transferTo(amount, receiver)
    @balance -= amount
    add_log "Transferred #{amount} to account #{receiver.number}."
  end

  def transferredFrom(amount, sender)
    @balance += amount
    add_log "Transferred #{amount} from account #{sender.number}."
  end

  private

  def add_log(action_text)
    @audit_log.push "#{ DateTime.now }: #{action_text}; Balance: #{@balance}"
  end
end
