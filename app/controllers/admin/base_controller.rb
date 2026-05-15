class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!


  helper WillPaginateTurboHelper
  layout "admin"


  def authenticate_admin!
    unless current_user.admin?
      redirect_to '/'
    end
  end
end