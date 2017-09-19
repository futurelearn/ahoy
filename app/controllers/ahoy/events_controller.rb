module Ahoy
  class EventsController < Ahoy::BaseController
    def create
      events.first(Ahoy.max_events_per_request).each do |event|
        time = Time.zone.parse(event["time"]) rescue nil

        # timestamp is deprecated
        time ||= Time.zone.at(event["time"].to_f) rescue nil

        options = {
          id: event["id"],
          time: time
        }
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end

    private

    def events
      if params[:name] # single event
        [params]
      elsif params[:events] # multiple events
        params[:events]
      else
        begin
          parsed_body = ActiveSupport::JSON.decode(request.body.read)
          if parsed_body[:name]
            [parsed_body]
          elsif params[:events]
            parsed_body
          else
            []
          end
        rescue ActiveSupport::JSON.parse_error
          # do nothing
          []
        end
      end
    end
  end
end
