class SecureDataStoragesController < ApplicationController
  before_action :set_sds_using_parameter, only: [:show]
  before_action :set_sds_using_payload, only: [:update]
  before_action :validate_type, only: [:update]

  def new
    @sds = SecureDataStorage.rand(@audience)
    render json: @sds, status: :ok
  end

  def show
    # return fake data, if the token could not be found
    unless @sds
      @sds = SecureDataStorage.new
    end
    render json: @sds, status: :ok
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

  def set_sds_using_parameter
    set_sds(HVCrypto::JWT.decode(params[:token], @audience))
  end

  def set_sds_using_payload
    set_sds(HVCrypto::JWT.decode(sds_params[:id], @audience))
  end

  def set_sds(token = nil)
    begin
      raise ActiveRecord::RecordNotFound unless token

      @sds = SecureDataStorage.find_by_token(token)
      @sds.audience = @audience
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
