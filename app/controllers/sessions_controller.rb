# This controller handles the login/logout function of the site.  
class SessionsController < BaseController
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required
  end  
  
  def index
    redirect_to :action => "new"
  end  
  
  # render new.rhtml
  def new
    redirect_to user_path(current_user) and return if current_user
    render :layout => 'beta' if AppConfig.closed_beta_mode
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in? && self.current_user.active?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { 
            :value => self.current_user.remember_token , 
            :expires => self.current_user.remember_token_expires_at }
      end
      #redirect_to dashboard_user_path(current_user)
      redirect_to application_url
      flash[:notice] = :thanks_youre_now_logged_in.l
      Log.log_activity(@user, 'login', @user)
      
    else
			unless self.current_user.active?
		    flash[:notice] = 'Seu cadastro precisa ser confirmado'
		    self.current_user = nil
		    render "users/resend_activation"
			else
		    flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
		    redirect_to teaser_path and return if AppConfig.closed_beta_mode        
		    render :action => 'new'
			end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :youve_been_logged_out_hope_you_come_back_soon.l
    #redirect_to new_session_path
    redirect_to application_url
  end

end
