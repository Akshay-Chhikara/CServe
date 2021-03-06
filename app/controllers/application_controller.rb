class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  protected

  def after_sign_in_path_for(resource)
    admins_path
  end

  def after_sign_out_path_for(resource)
    sign_in_path
  end

  #FIXME_AB: Why this method ending with question mark?. Also this should be named as validate_subdomain
  def check_subdomain?
    subdomain = request.subdomain
    if subdomain == 'www'
      redirect_to root_url(host: Rails.application.config.action_mailer.default_url_options[:host])
    elsif subdomain.blank? || Company.find_by(subdomain: subdomain).nil?
      flash[:alert] = 'Get Registered First'
      redirect_to root_url(host: Rails.application.config.action_mailer.default_url_options[:host])
    end
  end

end
