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

  private

  def set_slot
  end

end
