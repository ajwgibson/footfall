# frozen_string_literal: true

module UsersHelper
  def show_avatar(user, center = false)
    render partial: 'avatar', locals: { user: user, center: center, size: '' }
  end

  def show_avatar_xs(user, center = false)
    render partial: 'avatar', locals: { user: user, center: center, size: '-xs' }
  end

  def show_avatar_small(user, center = false)
    render partial: 'avatar', locals: { user: user, center: center, size: '-sm' }
  end

  def show_avatar_large(user, center = false)
    render partial: 'avatar', locals: { user: user, center: center, size: '-lg' }
  end
end
