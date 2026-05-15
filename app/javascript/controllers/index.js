import { application } from "controllers/application"

import FlashController from "controllers/flash_controller"
import MeterReadingController from "controllers/meter_reading_controller"
import InvoiceBatchController from "controllers/invoice_batch_controller"
import VatController from "controllers/vat_controller"

application.register("flash", FlashController)
application.register("meter-reading", MeterReadingController)
application.register("invoice-batch", InvoiceBatchController)
application.register("vat", VatController)