require 'rails_helper'

RSpec.describe SecureDataStoragesController, type: :controller do

  describe "GET #show" do
    xit "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    xit "returns http success" do
      patch :update
      expect(response).to have_http_status(:success)
    end
  end

end
