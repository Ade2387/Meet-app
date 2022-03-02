class GoogleApiController < ApplicationController
  def redirect
    client = Signet::OAuth2::Client.new(client_options)

    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]
    response = client.fetch_access_token!

    session[:authorization] = response

    redirect_to "/dashboard_events"
  end

  def calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    # raise
    @calendar_list = service.list_calendar_lists
  end

  def dashboard_events
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    # @event_list = service.list_events("primary")

    # the timeframe
    time_min = DateTime.yesterday.rfc3339
    time_max = DateTime.tomorrow.rfc3339

    # the requests for the different users events within this timeframe
    @event_list = service.list_events("bas_neyt@hotmail.com", time_min: time_min, time_max: time_max)
    @event_list2 = service.list_events("olafdery@gmail.com", time_min: time_min, time_max: time_max)
    # raise
  end

  private

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
