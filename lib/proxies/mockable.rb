module Proxies
  module Mockable

    def initialize_mocks
      if defined? WebMock
        on_request.set_response(@response_overrides || {})
      end
    end

    def on_request(options={})
      MockHttpInteraction.new(mock_request.merge(options), mock_response)
    end

    def override_json(&blk)
      on_request.override_json(&blk)
    end

    def set_response(options={})
      @response_overrides ||= {}
      @response_overrides.merge! options
      on_request.set_response(@response_overrides)
    end

    def mock_request
      {
        method: :get,
        uri_matching: @settings.base_url
      }
    end

    def mock_response
      {
        status: 200,
        headers: {'Content-Type' => 'application/json'},
        body: mock_json
      }
    end

    def mock_json
      ''
    end

    def read_file(*args)
      path = Rails.root.join(*args)
      Timeshifter.process(File.read path) if File.exist? path
    end

  end
end
