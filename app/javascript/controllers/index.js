import { application } from "controllers/application"

import FlashController from "./flash_controller"
import MeterReadingController from "./meter_reading_controller"
import InvoiceBatchController from "./invoice_batch_controller"
import VatController from "./vat_controller"

application.register("flash", FlashController)
application.register("meter-reading", MeterReadingController)
application.register("invoice-batch", InvoiceBatchController)
application.register("vat-controller", VatController)