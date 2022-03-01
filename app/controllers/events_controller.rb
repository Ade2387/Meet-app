class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  def index
    @user = User.find(params[:user_id])
    @events = Event.all
  end

  def show
  end

  def new
    @user = User.find(params[:user_id])
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    @event.save
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Your meeting has been successfully updated.'
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
