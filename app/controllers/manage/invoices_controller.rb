class Manage::InvoicesController < Manage::BaseController
  def index
    @invoices = Invoice.where(user_id: current_user.id).paginate(:page => params[:page], :per_page => 20)
  end

  def gas
    @invoices = Invoice
                  .where(user_id: current_user.id)
                  .where("reference ILIKE ?", "%gas%")
                  .paginate(page: params[:page], per_page: 20)

  end

  def electric
    @invoices = Invoice
                  .where(user_id: current_user.id)
                  .where("reference ILIKE ?", "%electric%")
                  .paginate(page: params[:page], per_page: 20)
  end

  def pitch_fees
    @invoices = Invoice
                  .where(user_id: current_user.id)
                  .where("reference ILIKE ?", "%Pitch Fee%")
                  .paginate(page: params[:page], per_page: 20)
  end

  def utilities
    @invoices = Invoice
                  .where(user_id: current_user.id)
                  .where("reference ILIKE ?", "%Utilities%")
                  .paginate(page: params[:page], per_page: 20)
  end

  def late_payments
    @invoices = Invoice.where(user_id: current_user.id, reference: 'Late Payments').paginate(page: params[:page], per_page: 20)
  end

  def lodge_payments
    @invoices = Invoice.where(user_id: current_user.id, reference: 'Lodge Payments').paginate(page: params[:page], per_page: 20)
  end

  def show
    @invoice = Invoice.find(params[:id])

    pdf = Prawn::Document.new

    full_doc = "#{Rails.root}/public/new_branding_letter_head_2.png"
    pdf.image full_doc, :at => [-40,760], :width => 617

    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')
    pdf.text(' ')

    pdf.text "<font size='24'><u><b>INV-" + @invoice.id.to_s + "</b></u></font>", :inline_format => true, align: :center

    pdf.text(' ')

    pdf.text('Invoice Date: ' +  (@invoice.due_date).strftime("01/%m/%Y"))
    pdf.text('Name: ' + @invoice.user.full_name)
    pdf.text('Park Name: ' + @invoice.pitch.park.name)
    pdf.text('Plot Number: ' + @invoice.pitch.pitch_number.to_s)

    pdf.text(" ")

    pdf.table(@invoice.reading_rows, width: 500, cell_style: { inline_format: true }) if @invoice.reading_rows.any?

    pdf.text(" ")

    pdf.table(@invoice.charge_rows, width: 500, cell_style: { inline_format: true })

    pdf.text(" ")

    pdf.text "<font size='14'><u><b>PAYMENT TERMS</b></u></font>", :inline_format => true
    pdf.text('This invoice will be collected via direct debit on the 1st of the month.')
    pdf.text('Any failed direct debit instruction will incur a £25 default charge which will be added onto the next direct debit request.')

    pdf.text "<font size='14'><u><b>Invoice Queries</b></u></font>", :inline_format => true
    pdf.text('Please email info@nelsonparks.co.uk if you do have any invoice queries')

    full_doc_bottom = "#{Rails.root}/public/new_branding_letter_footer_1.png"
    pdf.image full_doc_bottom, :at => [-40,175], :width => 617

    send_data pdf.render,
              filename: "invoice-#{@invoice.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end
end
