# Replace this placeholder with real infrastructure. It exists so `terraform validate` succeeds on a fresh copy.
resource "terraform_data" "stack_placeholder" {
  input = {
    workload    = var.workload
    environment = var.environment
  }
}
