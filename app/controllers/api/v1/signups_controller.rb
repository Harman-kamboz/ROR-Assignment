module Api
  module V1
    class SignupsController < ApplicationController
      def create
        company = Company.new(name: signup_params[:company_name])
        user = company.users.new(
          name: signup_params[:name],
          email: signup_params[:email],
          password: signup_params[:password],
          password_confirmation: signup_params[:password],
          role: "admin"
        )

        if company_name_blank?
          return render_errors("Company name is required")
        end

        ActiveRecord::Base.transaction do
          company.save!
          user.save!
        end

        token = JsonWebToken.encode(sub: user.id, type: "User", company_id: company.id)
        render json: { token: token, user: UserSerializer.as_json(user) }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render_record_errors(e.record)
      end

      private

      def signup_params
        params.permit(:name, :email, :password, :company_name)
      end

      def company_name_blank?
        signup_params[:company_name].to_s.strip.blank?
      end
    end
  end
end
