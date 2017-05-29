class SecureDataStoragesController < ApplicationController
  before_action :set_sds, only: [:show, :update]
  before_action :validate_type, only: [:update]

  def new
    @sds = SecureDataStorage.rand(audience)
    render json: @sds, status: :ok
  end

  def show
    if @sds
      render json: @sds, status: :ok
    else
      new
    end
  end

  def update
    # faked data are not stored
    if @sds
      if allowed_sds_params && @sds.update_attributes(allowed_sds_params)
        head :no_content
      else
        render_error(@sds, :unprocessable_entity)
      end
    else
      head :bad_request
    end
  end


private

  def audience
    aud_claim = {}
    api_key = request.headers["X-Api-Key"]
    aud_claim[:aud] = HVCrypto::Synchron.decode(api_key) if api_key
    aud_claim
  end

  def set_sds
    begin
      token = HVCrypto::JWT.decode(params[:token], audience)
      raise ActiveRecord::RecordNotFound unless token
      @sds = SecureDataStorage.find_by_token(token)
      @sds.audience = audience
    rescue # ActiveRecord::RecordNotFound
      @sds = nil
    end
  end

  def sds_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end

  def allowed_sds_params
    sds_params.slice(:document)
  end
end
