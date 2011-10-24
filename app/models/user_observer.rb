class UserObserver < ActiveRecord::Observer
  def before_update(user)
    Log.setup(user, :action => :update, :text => "atualizou o perfil")
  end

  def after_create(user)
    environment = Environment.find_by_path('ava-redu')
    return nil unless environment

    environment.courses.each { |c| c.join(user) }
    UserNotifier.user_signedup(user).deliver
  end
end