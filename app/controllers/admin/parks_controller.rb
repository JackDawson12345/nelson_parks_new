class Admin::ParksController < Admin::BaseController
  def index
    @parks = Park.all
    @park = Park.new
  end

  def create
    @park = Park.new(park_params)

    if @park.save
      redirect_to admin_parks_path, notice: "Park created successfully."
    else
      @parks = Park.all
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @park = Park.find(params[:id])

    if @park.update(park_params)
      redirect_to admin_parks_path, notice: "Park updated successfully."
    else
      @parks = Park.all
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @park = Park.find(params[:id])
    @park.destroy

    redirect_to admin_parks_path, notice: "Park deleted successfully."
  end

  private

  def park_params
    params.require(:park).permit(:name, :location)
  end
end