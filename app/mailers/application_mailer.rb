# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  OPERATIONS_EMAIL = "hcb@hcb.cyteon.dev"

  DOMAIN = "hcb.cyteon.dev"
  default from: "HCB (Cyteon's Instance) <hcb@hcb.cyteon.dev>"
  layout "mailer/default"

  # allow usage of application helper
  helper :application

  protected

  def hcb_email_with_name_of(object)
    name = object.try(:name)
    if name.present?
      name += " via HCB (Cyteon's Instance)"
    else
      name = "HCB (Cyteon's Instance)"
    end

    email_address_with_name("hcb@cyteon.dev", name)
  end

end
