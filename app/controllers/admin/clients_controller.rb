class Admin::ClientsController < Admin::BaseController
  def index
    @clients = User
                 .where(admin: false)
                 .includes(pitch: :park)
                 .joins(:pitch)
                 .order('pitches.pitch_number ASC')
                 .paginate(page: params[:page], per_page: 20)
    @client = User.new
  end

  def create
    @client = User.new(client_params.except(:pitch_id))
    @client.admin = false
    @client.password = SecureRandom.hex(12)

    if @client.save
      assign_pitch(@client, client_params[:pitch_id])
      redirect_to admin_clients_path, notice: "Client created successfully."
    else
      @clients = User.where(admin: false).includes(pitch: :park)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @client = User.find(params[:id])

    if @client.update(client_params.except(:pitch_id))
      assign_pitch(@client, client_params[:pitch_id])
      redirect_to admin_clients_path, notice: "Client updated successfully."
    else
      @clients = User.where(admin: false).includes(pitch: :park)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @client = User.find(params[:id])
    @client.destroy

    redirect_to admin_clients_path, notice: "Client deleted successfully."
  end

  private

  def client_params
    params.require(:user).permit(:full_name, :email, :phone_number, :pitch_id, :xero_id)
  end

  def assign_pitch(client, pitch_id)
    client.pitch&.update(user_id: nil)

    return if pitch_id.blank?

    Pitch.find(pitch_id).update(user: client)
  end
end