class Manage::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_manage!

  layout "manage"

  def authenticate_manage!
    if current_user.admin?
      redirect_to '/admin/dashboard'
    end
  end
end