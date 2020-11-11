class PendingResponsiblePersonInvitationsPresenter
  include DateHelper

  attr_reader :invitations

  ACTIVE_INVITES_PREFIX = "Check your email inbox for your invite, sent".freeze
  EXPIRED_INVITES_PREFIX = "Your invite has expired and needs to be resent. You were invited by".freeze

  def initialize(invitations)
    @invitations = invitations
  end

  def invitations_text
    responsible_persons_invitations.transform_values do |rp_invites|
      if rp_invites.size == 1
        single_invitation_text(rp_invites.first)
      elsif rp_invites.size > 1
        multiple_invitations_text(rp_invites)
      end
    end
  end

private

  def responsible_persons_invitations
    invitations.each_with_object(ActiveSupport::OrderedHash.new) do |invitation, hash|
      responsible_person = invitation.responsible_person.name
      if hash[responsible_person]
        hash[responsible_person] << invitation
      else
        hash[responsible_person] = [invitation]
      end
    end
  end

  def single_invitation_text(invite)
    if invite.expired?
      "#{EXPIRED_INVITES_PREFIX} <span class='no-wrap'>#{invite.inviting_user.name}.</span>"
    else
      "#{ACTIVE_INVITES_PREFIX} <span class='no-wrap'>#{display_full_month_date(invite.created_at)}.</span>"
    end
  end

  def multiple_invitations_text(invites)
    if invites.all?(&:expired?)
      EXPIRED_INVITES_PREFIX + " " + inviting_user_names_list(invites)
    else
      latest_invite_date = display_full_month_date(invites.reject(&:expired?).map(&:created_at).max)
      "#{ACTIVE_INVITES_PREFIX} <span class='no-wrap'>#{latest_invite_date}.</span>"
    end
  end

  def inviting_user_names_list(invites)
    names_list = "<span class='no-wrap'>#{invites.first.inviting_user.name}</span>"
    invites.drop(1).each_with_index do |invite, index|
      names_list << if index == invites.size - 2 # Last element index after removing the first invite from the array
                      " and <span class='no-wrap'>#{invite.inviting_user.name}.</span>"
                    else
                      ", <span class='no-wrap'>#{invite.inviting_user.name}</span>"
                    end
    end
    names_list
  end
end
