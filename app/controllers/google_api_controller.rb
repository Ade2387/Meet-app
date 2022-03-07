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
    redirect_to "/dashboard"
  end

  def calendars
    call_google_api
    @calendar_list = @service.list_calendar_lists
  end

  def dashboard_events
    call_google_api

    @time_min = "2022-03-02T8:30:00+01:00"
    @time_max = "2022-03-02T18:00:00+01:00"
    attendees = ["bas_neyt@hotmail.com", "olafdery@gmail.com"]

    @event_list = call_list_events(@time_min, @time_max, attendees[0])
    @event_list2 = call_list_events(@time_min, @time_max, attendees[1])
  end

  def timeslots
    call_google_api
    # fetching the events from the attendees whitin the specific timeframe



    @time_min = "2022-03-02T8:30:00+01:00"
    @time_max = "2022-03-02T18:00:00+01:00"
    attendees = ["bas_neyt@hotmail.com", "olafdery@gmail.com"]


    @user1 = []
    @user2 = []
    @event_list_user1 = call_list_events(@time_min, @time_max, attendees[0])
    @event_list_user2 = call_list_events(@time_min, @time_max, attendees[1])

    # creating the occupied arrays for each user
    create_array(@event_list_user1, @user1)
    create_array(@event_list_user2, @user2)

    # OPTIONAL: boundries

    # combining the user arrays (user1, user2)
    @combined_array = merge_arrays(@user1, @user2)

    # sorting the subarrays based on the first military time
    @sorted_array = @combined_array.sort { |time1, time2| time1[0] <=> time2[0] }

    # refactoring the overlapping timeframes

    compact_array(@sorted_array)

    # calculating free time array
    @free_time = free_time(@sorted_array)

    # creating the timeslots (depending on the duration of the event in our case 30min => .5 hour)
    # input = 30
    duration = 30.minutes
    @timeslots = create_timeslots(duration, @free_time)
  end

  def create_event
    call_google_api

    event = Google::Apis::CalendarV3::Event.new(
      summary: 'Event created from vscode',
      description: 'A chance to hear more about Google\'s developer products.',
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: '2022-03-3T15:30:00-00:00',
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: '2022-03-3T17:00:00-00:00',
      ),
      attendees: [
        Google::Apis::CalendarV3::EventAttendee.new(
          email: 'bas_neyt@hotmail.com'
        ),
        Google::Apis::CalendarV3::EventAttendee.new(
          email: 'olafdery@gmail.com'
        )
      ]
    )

    @service.insert_event('primary', event)
    # puts "Event created: #{result.html_link}"
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

  def create_array(array, user)
    array.items.each do |event|
      user.push([event.start.date_time, event.end.date_time])
    end
  end

  def merge_arrays(array1, array2)
    merged = []
    array1.each do |x|
      merged.push(x)
    end
    array2.each do |x|
      merged.push(x)
    end
    return merged
  end

  def compact_array(sorted_array)
    index = 0
    while index < (sorted_array.length - 1)
      if sorted_array[index][1] >= sorted_array[index + 1][0]
        if sorted_array[index + 1][1] < sorted_array[index][1]
          sorted_array.delete_at(index + 1)
        else
          new_slot = [sorted_array[index][0], sorted_array[index + 1][1]]
          set = [index, index + 1]
          sorted_array.delete_if.with_index { |_, i| set.include? i }
          sorted_array.insert(index, new_slot)
        end
      else
        index += 1
      end
    end
  end

  def free_time(sorted_array)
    free_time = []
    indexx = 0
    while sorted_array.length > (free_time.length + 1)
      new_frame = [sorted_array[indexx][1], sorted_array[indexx + 1][0]]
      free_time.push(new_frame)
      indexx += 1
    end
    return free_time
  end

  def create_timeslots(duration, free_time_array)
    timeslots = []
    free_time_array.each do |interval|
      subinterval = (interval[0] + duration)
      loops = 0
      while (subinterval) <= interval[1]
        if loops != 0
          slot = [subinterval - duration, subinterval]
          timeslots.push(slot)
          subinterval += duration

        else
          slot = [interval[0], subinterval]
          timeslots.push(slot)
          subinterval += duration
          loops += 1
        end
      end
    end
    return timeslots
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
