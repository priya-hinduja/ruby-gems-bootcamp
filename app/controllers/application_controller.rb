class ApplicationController < ActionController::Base
  include PublicActivity::StoreController # save current_user using gem public_activity
  include Pundit
  include Pagy::Backend
  protect_from_forgery
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user!
  before_action :set_global_variables, if: :user_signed_in?
  after_action :user_activity

  def set_global_variables
    @ransack_courses = Course.ransack(params[:courses_search], search_key: :courses_search) # navbar search
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def user_activity
    current_user.try :touch
  end
end
