module Api
  module V1
    class ClientsController < BaseController
      before_action :require_user!

      def index
        clients = current_company.company_clients.includes(:client).order(:id)
        render json: clients.map { |cc| CompanyClientSerializer.as_json(cc) }
      end

      def show
        company_client = current_company.company_clients.find_by(id: params[:id])
        return render_errors("Client not found", status: :not_found) unless company_client

        render json: CompanyClientSerializer.as_json(company_client)
      end

      def create
        company_client = Clients::UpsertForCompany.new(
          company: current_company,
          attrs: client_params
        ).call

        render json: CompanyClientSerializer.as_json(company_client), status: :created
      rescue Clients::UpsertForCompany::Error => e
        render_errors(e.message)
      rescue ActiveRecord::RecordInvalid => e
        render_record_errors(e.record)
      end

      def update
        company_client = current_company.company_clients.find_by(id: params[:id])
        return render_errors("Client not found", status: :not_found) unless company_client

        if company_client.update(client_params)
          render json: CompanyClientSerializer.as_json(company_client)
        else
          render_record_errors(company_client)
        end
      end

      private

      def client_params
        params.permit(:name, :email, :phone)
      end
    end
  end
end
