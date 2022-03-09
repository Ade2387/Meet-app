require 'date'
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
      if @user_ids.nil? == false
        @user_ids.each do |id|
          @user = User.find(id)
          @event.users << @user
        end
      end
      # creating the attendees email array
      emails = [@event.user.email]
      @event.users.each do |attendee|
        emails.push(attendee.email)
      end
      # calling the timeslot method with the required parameters
      # adding the condition if it's multiple days, we want to run it multiple times for each day individualy
      amount_days = @event.end_time.day - @event.start_time.day
      if amount_days != 0
        day_difference = 1
        days = [[@event.start_time, DateTime.new(@event.start_time.year, @event.start_time.month, @event.start_time.day,@event.end_time.hour, @event.end_time.min, 0, '+1')]]

        amount_days.times do
          part1 = DateTime.new(@event.start_time.year, @event.start_time.month, (@event.start_time.day + day_difference),@event.start_time.hour, @event.start_time.min, 0, '+1')
          part2 = DateTime.new(@event.start_time.year, @event.start_time.month, (@event.start_time.day + day_difference),@event.end_time.hour, @event.end_time.min, 0, '+1')
          days.push([part1, part2])
          day_difference += 1
        end
      else
        days = [@event.start_time, @event.end_time]
      end

      all_days_slots = []

      if amount_days != 0
        days.each do |day|
          all_days_slots.push(timeslots(day[0], day[1], emails, @event.duration))
        end
      else
        all_days_slots.push(timeslots(days[0], days[1], emails, @event.duration))
      end

      all_days_slots.each do |dayslots|
        dayslots.each do |dayslot|
          Slot.create(start_time: dayslot[0].strftime("%B-%d-%H:%M"), end_time: dayslot[1].strftime("%B-%d-%H:%M"), event_id: @event.id, status: "pending")
        end
      end

      # slotarray = timeslots(@event.start_time, @event.end_time, emails, @event.duration)
      # # create the timeslots for the event
      # slotarray.each do |slot|
      #   Slot.create(start_time: slot[0].strftime("%B-%d-%H:%M"), end_time: slot[1].strftime("%B-%d-%H:%M"), event_id: @event.id, status: "pending")
      # end
      redirect_to event_slots_path(@event)
    else
      render :new
    end
  end

  def edit
    @employees = User.where(company: current_user.company)
  end

  def update
    # @new_event = Event.new(event_params)
    # @new_event.user = current_user
    # @user_ids = params[:event][:users]
    create
    # if @new_event.create(event_params)
    Event.find(params[:id]).destroy
    # else
    #   render :edit
    # end
  end

  def destroy
    @event.destroy
    redirect_to "/dashboard", notice: "Your meeting was successfully deleted."
  end

  def timeslots(start_time, end_time, attendees, duration)
    call_google_api
    start_time = start_time.to_datetime
    end_time = end_time.to_datetime

    event_lists_attendees = []
    attendees.each do |attendee|
      x = call_list_events(start_time, end_time, attendee)
      event_lists_attendees.push(x)
    end

    test = []

    event_lists_attendees.each do |eventlist|
      test.push(create_array(eventlist, start_time, end_time))
    end

    while test.length > 1
      part = merge_arrays(test[0], test[1])
      set = [0, 1]
      test.delete_if.with_index { |_, i| set.include? i }
      test.insert(0, part)
    end
    test = test[0]

    sorted_test = test.sort { |time1, time2| time1[0] <=> time2[0] }

    compact_array(sorted_test)

    free_time_test = free_time(sorted_test)
    test_slots = create_timeslots(duration.minutes, free_time_test)
    # raise
    return test_slots
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
    @service.list_events(attendee, time_min: time_min, time_max: time_max, order_by: "starttime", single_events: true)
  end

  def create_array(array, start_time, end_time)

    answer = []

    boundrie1 = DateTime.new(start_time.to_datetime.year, start_time.to_datetime.month, start_time.to_datetime.day, [start_time.to_datetime.hour, 7].max, start_time.to_datetime.hour <= 7 ? 59 : start_time.to_datetime.min, 0, '+1')
    boundrie11 = DateTime.new(start_time.to_datetime.year, start_time.to_datetime.month, start_time.to_datetime.day, [start_time.to_datetime.hour, 8].max, start_time.to_datetime.hour <= 8 ? 0 : start_time.to_datetime.min, 0, '+1')
    boundrie2 = DateTime.new(end_time.to_datetime.year, end_time.to_datetime.month, end_time.to_datetime.day, [end_time.to_datetime.hour, 18].min, end_time.to_datetime.hour >= 18 ? 00 : end_time.to_datetime.min, 0, '+1')
    boundrie22 = DateTime.new(end_time.to_datetime.year, end_time.to_datetime.month, end_time.to_datetime.day, [end_time.to_datetime.hour, 18].min, end_time.to_datetime.hour >= 18 ? 01 : end_time.to_datetime.min, 0, '+1')

    # array.items[0].start.date_time.day
    answer.push([boundrie1, boundrie11])
    array.items.each do |event|
      answer.push([event.start.date_time, event.end.date_time])
    end
    answer.push([boundrie2, boundrie22])

    return answer
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
