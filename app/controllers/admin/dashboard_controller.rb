class Admin::DashboardController < Admin::BaseController
  def index
    @parks = Park.all
    @pitches = Pitch.all
    @clients = User.where(admin: false)
    @invoice_batches = InvoiceBatch.all.last(3)
  end
end