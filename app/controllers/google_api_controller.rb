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

    # the timeframe ( still to be inserted from the form)
    # @time_min = DateTime.yesterday.rfc3339
    # @time_max = (DateTime.tomorrow + 1).rfc3339

    @time_min = "2022-03-02T8:30:00+01:00"
    @time_max = "2022-03-02T18:00:00+01:00"

    # the requests for the different users events within this timeframe (when some1 selects the emails he want to add)
    @event_list = service.list_events("bas_neyt@hotmail.com", time_min: @time_min, time_max: @time_max)
    @event_list2 = service.list_events("olafdery@gmail.com", time_min: @time_min, time_max: @time_max)
    # raise
  end

  def timeslots
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    @time_min = "2022-03-02T8:30:00+01:00"
    @time_max = "2022-03-02T18:00:00+01:00"

    # fetching the attendees events whitin the timeframe
    @user1 = []
    @user2 = []
    @event_list_user1 = service.list_events("bas_neyt@hotmail.com", time_min: @time_min, time_max: @time_max)
    @event_list_user2 = service.list_events("olafdery@gmail.com", time_min: @time_min, time_max: @time_max)

    # creating the occupied arrays for each user
    @event_list_user1.items.each do |event|
      @user1.push([event.start.date_time.strftime('%H%M').to_i, event.end.date_time.strftime('%H%M').to_i])
    end
    @event_list_user2.items.each do |event|
      @user2.push([event.start.date_time.strftime('%H%M').to_i, event.end.date_time.strftime('%H%M').to_i])
    end

    # combining the user arrays (user1, user2)
    @combined = []
    @user1.each do |x|
      @combined.push(x)
    end
    @user2.each do |x|
      @combined.push(x)
    end

    # sorting the subarrays based on the first military time
    @x = @combined.sort { |time1, time2| time1[0] <=> time2[0] }

    # refactoring the overlapping timeframes
    refactored_cal = []
    index = 0
    # while index < @x.length
    #   if @x[index][1] > @x[index + 1][0]
    #     new_slot = [@x[index][0], @x[index + 1][1]]
    #     @x.delete_at(index + 1)
    #     @x.delete_at(index)
    #     @x.insert(0, new_slot)
    #     index += 2

    #   elsif @x[index][1] == @x[index + 1][0]
    #     refactored_cal.push([@x[index][0], @x[index + 1][1]])
    #     index += 1
    #     raise
    #   else
    #     refactored_cal.push(@x[index])
    #     refactored_cal.push(@x[index + 1])
    #     index += 1
    #   end
    # end
    # Combined: [[900, 1030], [1000, 1130], [1200, 1300], [1230, 1430], [1430, 1500], [1600, 1800]]
    # [[900, 1130], [1200, 1300], [1230, 1430], [1430, 1500], [1600, 1800]]
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
