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
    @event_list = service.list_events("bas_neyt@hotmail.com", time_min: @time_min, time_max: @time_max, order_by: "starttime", single_events: true)
    @event_list2 = service.list_events("olafdery@gmail.com", time_min: @time_min, time_max: @time_max, order_by: "starttime", single_events: true)

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
    @event_list_user1 = service.list_events("bas_neyt@hotmail.com", time_min: @time_min, time_max: @time_max, order_by: "starttime", single_events: true)
    @event_list_user2 = service.list_events("olafdery@gmail.com", time_min: @time_min, time_max: @time_max, order_by: "starttime", single_events: true)

    # creating the occupied arrays for each user
    @event_list_user1.items.each do |event|
      @user1.push([event.start.date_time, event.end.date_time])
    end

    @event_list_user2.items.each do |event|
      @user2.push([event.start.date_time, event.end.date_time])
    end
    # optional - boundries

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
    index = 0

    while index < (@x.length - 1)
      if @x[index][1] >= @x[index + 1][0]
        if @x[index + 1][1] < @x[index][1]
          @x.delete_at(index + 1)
        else
          new_slot = [@x[index][0], @x[index + 1][1]]
          set = [index, index + 1]
          @x.delete_if.with_index { |_, i| set.include? i }
          @x.insert(index, new_slot)
        end
      else
        index += 1
      end
    end

    # calculating free time
    indexx = 0
    @free_time = []
    while @x.length > (@free_time.length + 1)
      new_frame = [@x[indexx][1], @x[indexx + 1][0]]
      @free_time.push(new_frame)
      indexx += 1
    end

    # creating the timeslots (depending on the duration of the event in our case 30min => .5 hour)
    input = 30
    duration = input * 60
    timeslots = []
    @free_time.each do |interval|
      subinterval = interval[0] + duration
      while (subinterval) > interval[1]
        slot = [interval[0], interval[0] + duration]
        timeslots.push(slot)
      end
    end

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
