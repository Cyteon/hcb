# frozen_string_literal: true

class EventTagsController < ApplicationController
  include SetEvent
  before_action :set_event

  def create
    @event_tag = EventTag.find_or_create_by(name: params[:name].strip)
    authorize @event_tag

    @event_tag.save!

    if params[:event_id]
      @event = Event.find(params[:event_id])
      authorize @event, :toggle_event_tag?

      suppress ActiveRecord::RecordNotUnique do
        @event.event_tags << @event_tag
      end
    end

    redirect_back fallback_location: edit_event_path(@event, anchor: "admin_organization_tags")
  end

  def destroy
    @event_tag = EventTag.find(params[:id])
    authorize @event_tag

    @event_tag.destroy!

    redirect_back fallback_location: edit_event_path(@event, anchor: "admin_organization_tags")
  end

end
