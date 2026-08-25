module ErrorRenderable
  extend ActiveSupport::Concern

  private

  def render_errors(messages, status: :unprocessable_entity)
    render json: { errors: Array(messages) }, status: status
  end

  def render_record_errors(record)
    render_errors(record.errors.full_messages)
  end
end
