require 'rubygems'
require 'highline/import'
require './user'

$users = Array.new
$logged_in_user = nil

p "Welcome to your Ruby Bank. You can create a new user (type 'create_new_user <username>') or login (type 'login')."

def create_new_user(username)
  p "Creating new user with username #{username}."

  password = ask('Enter password:') { |q| q.echo = false }
  password_check = ask('Confirm password:') { |q| q.echo = false }

  if password != password_check
    p 'Password and confirmation are not the same!'
    create_new_user username
  else
    new_account_number = free_account_number
    new_user = User.new(username, password, new_account_number)
    $users.push(new_user)

    p "New user with username #{new_user.username} and account #{new_account_number} created."
  end
end

def login
  username = ask('Username:')
  password = ask('Enter password:') { |q| q.echo = false }

  $users.each do |user|
    next unless user.username == username
    next unless user.password == password

    $logged_in_user = user

    return "Welcome user #{username}. " +
        "You can deposit (type 'deposit <amount>'), " +
        "withdraw (type 'withdraw <amount>'), " +
        "or transfer (type 'transfer <amount>, <other account number>') money. " +
        "You can also show your balance (type 'show_balance'), or audit_log (type 'show_audit_log')"
  end

  'Incorrect username and/or password!'
end

def show_balance
  return login unless logged_in

  "Your current balance is: #{sprintf '%#.2f', $logged_in_user.account.balance}"
end

def deposit(amount)
  return login unless logged_in

  $logged_in_user.account.deposit(amount)

  "#{sprintf '%#.2f', amount} deposited in account #{$logged_in_user.account.number}"
end

def withdraw(amount)
  return login unless logged_in
  return "Denied: Not enough balance to withdraw #{sprintf '%#.2f', amount}." if amount > $logged_in_user.account.balance

  $logged_in_user.account.withdraw(amount)

  "#{sprintf '%#.2f', amount} withdrawn from account #{$logged_in_user.account.number}"
end

def transfer(amount, other_account_number)
  return login unless logged_in
  return 'Denied: Transfer amount must be positive.' if amount < 0
  return "Denied: Not enough balance to transfer #{sprintf '%#.2f', amount}." if amount > $logged_in_user.account.balance

  other_account = find_account(other_account_number)
  if other_account
    $logged_in_user.account.transferTo(amount, other_account)
    other_account.transferredFrom(amount, $logged_in_user.account)

    "#{sprintf '%#.2f', amount} transferred to account #{other_account_number}."
  else
    "Denied: account with number #{other_account_number} does not exist."
  end
end

def show_audit_log
  return login unless logged_in
  $logged_in_user.account.audit_log.each do |log|
    p log
  end
end

private

def logged_in
  if $logged_in_user.nil?
    p 'You are not logged in yet, please login first!'
    return false
  end
  true
end

def free_account_number
  max_value = $users.count + 1
  $users.each do |user|
    max_value = user.account.number + 1 if user.account.number >= max_value
  end

  max_value
end

def find_account(number)
  $users.each do |user|
    return user.account if user.account.number == number
  end

  false
end
