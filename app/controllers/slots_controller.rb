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
    if event.save
      # event.slots.destroy_all
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

end
