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
      if params[:name]
        # legacy API and AMP
        [request.params]
      elsif params[:events]
        request.params[:events]
      else
        data =
          if params[:events_json]
            request.params[:events_json]
          else
            request.body.read
          end
        begin
          case (parsed = ActiveSupport::JSON.decode(data))
          when Array
            parsed
          when Hash
            [parsed]
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
