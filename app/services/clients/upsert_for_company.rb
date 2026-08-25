module Clients
  class UpsertForCompany
    class Error < StandardError; end

    def initialize(company:, attrs:)
      @company = company
      @attrs = attrs.to_h.with_indifferent_access
    end

    def call
      validate_contact!
      client = find_or_create_global_client!
      upsert_company_client!(client)
    end

    private

    attr_reader :company, :attrs

    def name
      attrs[:name].to_s.strip.presence
    end

    def email
      attrs[:email].to_s.strip.downcase.presence
    end

    def phone
      attrs[:phone].to_s.strip.presence
    end

    def validate_contact!
      return if email.present? || phone.present?

      raise Error, "Email or phone is required"
    end

    def find_or_create_global_client!
      matched = match_existing_client
      return matched if matched

      Client.create!(
        name: name,
        email: email || EmailPresenter.generate_dummy,
        phone: phone
      )
    end

    def match_existing_client
      by_email = email.present? ? Client.find_by(email: email) : nil
      by_phone = phone.present? ? Client.find_by(phone: phone) : nil

      if by_email && by_phone && by_email.id != by_phone.id
        raise Error, "Email and phone match different clients"
      end

      by_email || by_phone
    end

    def upsert_company_client!(client)
      company_client = company.company_clients.find_or_initialize_by(client: client)
      company_client.assign_attributes(
        name: name,
        email: email,
        phone: phone
      )
      company_client.save!
      company_client
    end
  end
end
