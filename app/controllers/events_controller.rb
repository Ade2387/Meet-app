class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  def index
    @events = Event.all
  end

  def show
  end

  def new
    @employees = User.where(company: current_user.company)
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

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:start_at, :end_at, :description, :duration)
  end
end
