terraform {
  backend "local" {}
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "2.49.1"
    }
  }
}

variable "newrelic_personal_apikey" {}
variable "newrelic_account_id" {}
variable "eq_application" {}
variable "newrelic_platform" {}
variable "newrelic_customer" {}
variable "newrelic_prdalertpolicy" {}
variable "newrelic_nonprdalertpolicy" {}
variable "sql_cluster" {}
variable "sql_cluster1" {}
variable "sql_cluster2" {}
variable "fss_cluster" {}
variable "fss_cluster1" {}
variable "fss_cluster2" {}
variable "rabbitmq" {}
variable "rabbitmq_node1" {}
variable "rabbitmq_node2" {}
variable "synthetic" {}
variable "synthetic_name" {}
variable "apm_name" {}
variable "apm" {}

provider "newrelic" {
  account_id = var.newrelic_account_id
  api_key = var.newrelic_personal_apikey
  region = "US" # US or EU (defaults to US)
}
