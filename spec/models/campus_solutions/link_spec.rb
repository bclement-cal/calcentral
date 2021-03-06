describe CampusSolutions::Link do
  let(:placeholder_empl_id) { "1234567" }
  let(:proxy) { CampusSolutions::Link.new(fake: fake_proxy) }
  let(:url_id) { "UC_CX_APPOINTMENT_ADV_SETUP" }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
  end

  context 'mock proxy' do
    let(:fake_proxy) { true }
    let(:placeholders) { {:EMPLID => placeholder_empl_id, :IGNORED_PLACEHOLDER => "not used"} }

    let(:link_set_response) { proxy.get }
    let(:link_get_url_response) { proxy.get_url(url_id) }
    let(:link_get_url_with_bad_placeholder_response) { proxy.get_url(url_id, {:BAD_PLACEHOLDER => nil}) }
    let(:link_get_url_and_replace_placeholders_response) { proxy.get_url(url_id, placeholders) }
    let(:link_get_url_for_properties_response) { proxy.get_url(url_id) }

    before do
      allow_any_instance_of(CampusSolutions::Link).to receive(:xml_filename).and_return filename
    end

    context 'returns error message' do
      let(:filename) { 'link_api_error.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_set_response[:feed][:ucLinkResources][:isFault]).to eq "Y"
        expect(link_set_response[:feed][:ucLinkResources][:links]).not_to be
        expect(link_set_response[:feed][:ucLinkResources][:status][:details][:msgs][:msg][:messageSeverity]).to eq "E"
      end
    end

    context 'returns links as an array' do
      context 'with multiple links' do
        let(:filename) { 'link_api_multiple.xml' }

        it_should_behave_like 'a proxy that gets data'
        it 'returns data with the expected structure' do
          expect(link_set_response[:feed][:ucLinkResources][:links].count).to be > 1
        end
      end

      context 'with a single link' do
        let(:filename) { 'link_api.xml' }

        it_should_behave_like 'a proxy that gets data'
        it 'returns data with the expected structure' do
          expect(link_set_response[:feed][:ucLinkResources][:links].count).to eq 1
        end
      end
    end

    context 'returns a single link by its urlId' do
      let(:filename) { 'link_api_multiple.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_get_url_response[:link][:urlId]).to eq url_id
        # Verify that {placeholder} text is present
        expect(link_get_url_response[:link][:url]).to include("EMPLID={EMPLID}")
      end
    end

    context 'returns empty link when a placeholder value is blank' do
      let(:filename) { 'link_api.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_get_url_with_bad_placeholder_response[:link]).not_to be
      end
    end

    context 'replaces matching placeholders' do
      let(:filename) { 'link_api_multiple.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        # Verify that {placeholder} text is replaced
        expect(link_get_url_and_replace_placeholders_response[:link][:url]).to include("EMPLID=#{placeholder_empl_id}")
      end
    end

    context 'replaces the properties hash with only certain properties' do
      let(:filename) { 'link_api_multiple.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_get_url_response[:link][:properties]).not_to be
        expect(link_get_url_for_properties_response[:link][:ucFrom]).to be
        expect(link_get_url_for_properties_response[:link][:ucFromLink]).to be
        expect(link_get_url_for_properties_response[:link][:ucFromText]).to be
      end
    end
  end

  context 'real proxy', testext: true do
    let(:fake_proxy) { false }

    it_should_behave_like 'a proxy that gets data'
  end
end
