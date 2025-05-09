class Account::AccountsController < ApplicationController
  before_action :authenticate_user!

  def main
    @user = current_user
  end
end
