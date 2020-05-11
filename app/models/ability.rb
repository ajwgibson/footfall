# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.administrator?
      can :manage, :all
    else
      can :manage, Alarm
      can :manage, Device
      can :manage, DeviceGroup
      can :manage, DeviceDataRecord
    end
  end
end
