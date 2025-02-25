module Formatters
  class AsimFormatter
    def initialize(current_user = nil)
      @current_user = current_user
    end

    def call(data)
      end_time = Time.zone.now.utc
      start_time = end_time - (data[:duration] || 0)

      {
        "EventCount" => 1,
        "EventStartTime" => format_time(start_time),
        "EventEndTime" => format_time(end_time),
        "EventType" => event_type(data),
        "EventResult" => event_result(data),
        "EventSeverity" => map_severity(data[:level]),
        "EventOriginalSeverity" => data[:level],
        "EventSchema" => "ProcessEvent",
        "EventSchemaVersion" => "0.1.4",
        "EventProduct" => "PSD",
        "EventProductVersion" => Rails.version,
        "EventVendor" => "Ruby on Rails",
        "EventOwner" => data[:owner],
        "ActingAppType" => "Ruby on Rails",
        "SrcIpAddr" => data[:remote_ip],
        "SrcPortNumber" => ENV["PORT"] || 3000,
        "IpAddr" => data[:remote_ip],
        "SrcUserId" => @current_user&.id,
        "HttpUserAgent" => data[:user_agent],
        "Dvc" => ENV["DOMAIN"] || "unknown",
        "DvcDomain" => ENV["DOMAIN"] || "unknown",
        "AdditionalFields" => {
          "RailsLogFormatterAsimVersion" => "1.0.0",
          "TraceHeaders" => trace_headers(data),
          "RawLog" => data.to_json,
        },
      }.to_json
    end

  private

    def format_time(time)
      time.iso8601 if time
    end

    def event_type(data)
      controller = data[:controller]
      action = data[:action]
      if controller && action
        "#{controller}##{action}"
      else
        "UnknownEvent"
      end
    end

    def event_result(data)
      status = data[:status]
      if status
        status >= 400 ? "Failure" : "Success"
      else
        "NA"
      end
    end

    def map_severity(level)
      case level.to_s.upcase
      when "DEBUG"
        "Informational"
      when "INFO"
        "Informational"
      when "WARN"
        "Medium"
      when "ERROR"
        "High"
      when "FATAL"
        "High"
      else
        "Informational"
      end
    end

    def trace_headers(data)
      {
        "X-Request-Id" => data[:request_id],
      }
    end
  end
end
