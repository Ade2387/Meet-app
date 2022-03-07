class SlotsController < ApplicationController
  before_action :set_slot, only: [:update, :destroy]
  def index
    @event = Event.find(params[:event_id])
    @slots = Slot.all
  end

  def new
    @event = Event.find(params[:event_id])
    @slots = Slot.new
  end

  def create
  end

  def update
  end

  def destroy
  end

  def update_event
    event = Slot.find(params[:id]).event
    event.start_time = slot_params[:start_time]
    event.end_time = slot_params[:end_time]
    attendees_list = []
    attendees_list.push(event.user.email)
    event.user_events.each do |user|
      attendees_list << user.user.email
    end
    if event.save
      call_google_api
      final_event = Google::Apis::CalendarV3::Event.new(
        summary: event.name,
        description: event.description,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: event.start_time.to_datetime - 1.hour,
          time_zone: 'Europe/Brussels'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: event.end_time.to_datetime - 1.hour,
          time_zone: 'Europe/Brussels'
        ),
        attendees: attendees_list.map { |t| Google::Apis::CalendarV3::EventAttendee.new(email: t) }
      )
      @service.insert_event('primary', final_event)
      redirect_to "/dashboard", notice: 'Your meeting has been successfully created.'
    else
      render :index
    end
  end

  private

  def set_slot
  end

  def slot_params
    params.require(:slot).permit(:start_time, :end_time)
  end

  def create_event(event)
    call_google_api

    @service.insert_event('primary', event)
  end

  def call_google_api
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = client
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
