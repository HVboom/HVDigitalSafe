class SecureDataStoragesController < ApplicationController
  before_action :set_sds, only: [:show, :update]
  before_action :validate_type, only: [:update]

  def new
    @sds = SecureDataStorage.rand
    render json: @sds, status: :ok
  end

  def show
    render json: @sds, status: :ok
  end

  def update
    if allowed_sds_params && @sds.update_attributes(allowed_sds_params)
      head :no_content
    else
      render_error(@sds, :unprocessable_entity)
    end
  end


  private

  def set_sds
    begin
      @sds = SecureDataStorage.find_by_token(HVCrypto::JWT.decode(params[:token]))
    rescue ActiveRecord::RecordNotFound
      # fake the data, if it is an illigal attempt
      @sds = SecureDataStorage.new
    end
  end

  def sds_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end

  def allowed_sds_params
    sds_params.slice(:document)
  end
end
