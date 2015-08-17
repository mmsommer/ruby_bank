require './account'

class User
  attr_reader :account, :username, :password

  def initialize(username, password, account_number)
    @username = username
    @password = password
    @account = Account.new(account_number)
  end
end
