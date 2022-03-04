class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.all
  end

  def show
  end

  def new
    @employees = User.where(company: current_user.company).where.not(id: current_user.id)
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    @user_ids = params[:event][:users]
    if @event.save
      @user_ids.each do |id|
        @user = User.find(id)
        @event.users << @user
      end
      # creating the attendees email array
      emails = [@event.user.email]
      @event.users.each do |attendee|
        emails.push(attendee.email)
      end
      # calling the timeslot method with the required parameters
      timeslots(@event.start_time, @event.end_time, emails)

      redirect_to user_events_path(current_user)
    else
      render :new
    end

  end

  def edit
    @employees = User.where(company: current_user.company)
  end

  def update
    if @event.update(event_params)
      redirect_to user_events_path(current_user), notice: 'Your meeting has been successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Your meeting was successfully deleted."
  end

  def timeslots(start_time, end_time, attendees)
    call_google_api
    # fetching the events from the attendees whitin the specific timeframe
    # @time_min = "2022-03-02T8:30:00+01:00"
    # @time_min = start_time
    # @time_max = "2022-03-02T18:00:00+01:00"
    # @time_max = end_time
    # attendees = ["bas_neyt@hotmail.com", "olafdery@gmail.com"]
    event_lists_attendees = []
    attendees.each do |attendee|
      x = call_list_events(start_time, end_time, attendee)
      event_lists_attendees.push(x)
    end
    raise


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

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:start_time, :end_time, :description, :duration, :name)
  end

  def call_google_api
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = client
  end

  def call_list_events(time_min, time_max, attendee)
    @service.list_events(attendee.to_s, time_min: time_min, time_max: time_max, order_by: "starttime", single_events: true)
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
