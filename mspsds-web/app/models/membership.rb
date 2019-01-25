class Membership < Shared::Web::Membership
end
Membership.all if Rails.env.development?
