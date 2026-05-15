class Admin::PitchesController < Admin::BaseController
  def index
    @pitches = Pitch.includes(:park, :user)
                    .order(Arel.sql('CAST(pitch_number AS INTEGER) ASC'))
                    .paginate(page: params[:page], per_page: 20)
    @pitch = Pitch.new
  end

  def create
    @pitch = Pitch.new(pitch_params)

    if @pitch.save
      redirect_to admin_pitches_path, notice: "Pitch created successfully."
    else
      @pitches = Pitch.includes(:park, :user)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @pitch = Pitch.find(params[:id])

    if @pitch.update(pitch_params)
      redirect_to admin_pitches_path, notice: "Pitch updated successfully."
    else
      @pitches = Pitch.includes(:park, :user)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @pitch = Pitch.find(params[:id])
    @pitch.destroy

    redirect_to admin_pitches_path, notice: "Pitch deleted successfully."
  end

  private

  def pitch_params
    params.require(:pitch).permit(
      :pitch_number,
      :park_id,
      :pitch_type,
      :status,
      :user_id
    )
  end
end