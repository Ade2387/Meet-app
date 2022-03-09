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

  private

  def call_google_api
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = client
  end

  def call_list_events(time_min, time_max, attendee)
    return @service.list_events(attendee.to_s, time_min: time_min, time_max: time_max, order_by: "starttime", single_events: true)
  end

  def client_options
    {
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: ENV["CALLBACK_URL"]
    }
  end
end
