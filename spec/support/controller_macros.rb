# frozen_string_literal: true

module ControllerMacros
  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryBot.create(:administrator)
      sign_in user
    end
  end
end
