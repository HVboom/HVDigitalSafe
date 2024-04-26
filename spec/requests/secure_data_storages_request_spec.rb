require 'rails_helper'

RSpec.shared_examples 'Validate JSON API structure' do
  let(:valid_structure) do
    {
      data: {
        type: 'secure-data-storages',
        id: String,
        attributes: {
          document: String
        }
      }
    }
  end

  it "Returns a valid JSON API structure", aggregate_failures: true do
    expect(response).to have_http_status(:success)
    expect(response.content_type).to match(%r{application/vnd\.api\+json})
    expect(response.body).to be_json.with_content(valid_structure)
    expect(response.body).to be_json.with_content(HVCrypto::JWT::PATTERN).at_path('data.id')
  end
end

RSpec.shared_examples 'Unauthorized' do
  it "Returns status Unauthorized" do
    expect(response).to have_http_status(:unauthorized)
  end
end
RSpec.shared_examples 'Bad Request' do
  it "Returns status Bad Request and update fails" do
    expect(response).to have_http_status(:bad_request)

    get show_path(valid_token), headers: valid_headers
    expect(response.body).to be_json.with_content(orginal_document).at_path('data.attributes.document')
  end
end

RSpec.shared_examples 'Fake data' do
  it "Returns fake data" do
    expect(response.body).not_to be_json.with_content(valid_token).at_path('data.id')
    expect(response.body).not_to be_json.with_content(orginal_document).at_path('data.attributes.document')
  end
end


def create_api_key(key = 'Test')
  audience = {}
  audience[:iss] = Rails.application.class.module_parent_name
  audience[:aud] = Rails.application.credentials[:api_key_aud]

  HVCrypto::JWT.encode(key, audience)
end

def manipulate_string(text)
  'XXXXX' + text[5..text.length]
end

def token
  json_response[:data][:id]
end
def document
  json_response[:data][:attributes][:document]
end

def headers(api_key = create_api_key)
  headers = { 'Accept': 'application/vnd', 'Content-Type': 'application/vnd.api+json' }
  headers['X-API-Key'] = api_key
  headers
end

RSpec.describe 'SecureDataStoragesApi', type: :request do
  let(:valid_headers) { headers }
  let(:invalid_headers) { headers(create_api_key('Invalid')) }
  let(:manipulated_headers) { headers(manipulate_string(create_api_key)) }

  let(:valid_token) { token }
  let(:invalid_token) { token }
  let(:manipulated_token) { manipulate_string(valid_token) }

  let(:orginal_document) { document }

  describe "GET /" do
    context 'with valid API key' do
      before(:each) do
        allow(SecureDataStorage).to receive(:number_of_seed_records).and_return(25)
        get root_path, headers: valid_headers
        valid_token
      end

      include_examples 'Validate JSON API structure'

      it "Returns random tokens for a safe deposit box" do
        get root_path, headers: valid_headers
        expect(response.body).not_to be_json.with_content(valid_token).at_path('data.id')
      end
    end

    context 'with manipulated API key' do
      before(:each) do
        allow(SecureDataStorage).to receive(:number_of_seed_records).and_return(1)
        get root_path, headers: manipulated_headers
      end

      include_examples 'Unauthorized'
    end
  end

  describe "GET /[:id]" do
    context 'with valid API key' do
      before(:each) do
        allow(SecureDataStorage).to receive(:number_of_seed_records).and_return(1)
        get root_path, headers: valid_headers
        orginal_document
        get show_path(valid_token), headers: valid_headers
      end

      include_examples 'Validate JSON API structure'

      it "Retrieve data for the given token" do
        expect(response.body).to be_json.with_content(valid_token).at_path('data.id')
        expect(response.body).to be_json.with_content(orginal_document).at_path('data.attributes.document')
      end

      context 'with invalid token' do
        before(:each) do
          get root_path, headers: invalid_headers
          get show_path(invalid_token), headers: valid_headers
        end

        include_examples 'Validate JSON API structure'
        include_examples 'Fake data'
      end

      context 'with manipulated token' do
        before(:each) { get show_path(manipulated_token), headers: valid_headers }

        include_examples 'Validate JSON API structure'
        include_examples 'Fake data'
      end
    end

    context 'with invalid API key' do
      before(:each) do
        allow(SecureDataStorage).to receive(:number_of_seed_records).and_return(1)
        get root_path, headers: valid_headers
        orginal_document
        get show_path(valid_token), headers: invalid_headers
      end

      include_examples 'Validate JSON API structure'
      include_examples 'Fake data'
    end

    context 'with manipulated API key' do
      before(:each) do
        allow(SecureDataStorage).to receive(:number_of_seed_records).and_return(1)
        get root_path, headers: valid_headers
        get show_path(valid_token), headers: manipulated_headers
      end

      include_examples 'Unauthorized'
    end
  end

  describe "PATCH /" do
    let(:sds) { json_response }
    let(:changed_document) { 'let it roll' }

    before(:each) do
      allow(SecureDataStorage).to receive(:number_of_seed_records).and_return(1)
      get root_path, headers: valid_headers
      valid_token
      orginal_document
      sds[:data][:attributes][:document] = changed_document
    end

    context 'with valid API key' do
      it "Retrieve changed data after update" do
        patch update_path, params: sds.to_json, headers: valid_headers
        expect(response).to have_http_status(:no_content)

        get show_path(valid_token), headers: valid_headers
        expect(response.body).to be_json.with_content(changed_document).at_path('data.attributes.document')
      end

      context 'with invalid token' do
        before(:each) do
          get root_path, headers: invalid_headers
          sds[:data][:id] = invalid_token
          patch update_path, params: sds.to_json, headers: valid_headers
        end

        include_examples 'Bad Request'
      end

      context 'with manipulated token' do
        before(:each) do
          sds[:data][:id] = manipulated_token
          patch update_path, params: sds.to_json, headers: valid_headers
        end

        include_examples 'Bad Request'
      end
    end

    context 'with invalid API key' do
      before(:each) do
        patch update_path, params: sds.to_json, headers: invalid_headers
      end

      include_examples 'Bad Request'
    end

    context 'with manipulated API key' do
      before(:each) do
        patch update_path, params: sds.to_json, headers: manipulated_headers
      end

      include_examples 'Unauthorized'
    end
  end
end
