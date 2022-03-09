class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def dashboard
    # Simple Calendar config:
    start_date = params.fetch(:start_date, Date.today).to_date
    # @meetings = Event.joins(:user_events).where('user_events.user_id = ?', current_user.id)
    @meetings = Event.joins(:user_events).where(start_time: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week, user: current_user)
                     .or(Event.joins(:user_events).where('user_events.user_id = ?', current_user.id)).distinct
  end
end
