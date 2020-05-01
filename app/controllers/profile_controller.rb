# frozen_string_literal: true

class ProfileController < ApplicationController
  def index
    @title = 'User profile'
  end

  def picture
    @title = 'Change profile picture'
  end

  def picture_create
    current_user.profile_picture.attach(params[:profile_picture])
    redirect_to(action: :index)
  end
end
