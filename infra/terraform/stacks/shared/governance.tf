# Subscription cost budget with email alerts at 50/80/100% actual and 100%
# forecasted spend.
resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "budget-${local.prefix}-monthly"
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  dynamic "notification" {
    for_each = {
      "actual-50"    = { threshold = 50, type = "Actual" }
      "actual-80"    = { threshold = 80, type = "Actual" }
      "actual-100"   = { threshold = 100, type = "Actual" }
      "forecast-100" = { threshold = 100, type = "Forecasted" }
    }
    content {
      enabled        = true
      threshold      = notification.value.threshold
      operator       = "GreaterThanOrEqualTo"
      threshold_type = notification.value.type
      contact_emails = var.budget_contact_emails
    }
  }
}
