class ApplicationController < ActionController::API
  before_action :validate_api_key
  before_action :validate_header

  def validate_api_key
    @audience = audience
    unless @audience && @audience[:aud]
      Rails.logger.error '!!! You are under attack! - no API key provided'
      unless @usage_api_key
        Rails.logger.warn %q{
          Maybe your setup is not completed.
          Please either setup the secret key *Rails.application.secrets.api_key* in HVKeyGuard
          (if this is your client application) or
          ensure to provide the header parameter *X-Api-Key* if you have written you own client
        }
        @usage_api_key = true
      end

      head :unauthorized and return
    end
  end

  def validate_header
    if ['POST','PUT','PATCH'].include? request.method
      if request.content_type != 'application/vnd.api+json'
        head :not_acceptable and return
      end
    end
  end

  def validate_type
    if params['data'] && params['data']['type']
      if params['data']['type'] == params[:controller].dasherize
        return true
      end
    end
    head :unprocessable_entity and return
  end

  private

  def render_error(resource, status)
    render json: resource, status: status, adapter: :json_api,
           serializer: ActiveModel::Serializer::ErrorSerializer
  end

  def audience
    aud_claim = {}
    api_key = request.headers['X-Api-Key']
    aud_claim[:aud] = HVCrypto::JWT.decode_api_key(api_key)
    aud_claim
  end
end
