terraform {
  required_version = ">= 0.13.0"
  required_providers {
    universe = {
      source = "github.com/operatorequals/universe"
      version = ">=0.1.0"
    }
  }
}

# KIBANA_PASSWORD is set from the Environment
provider "universe" {
  alias = "detection_rule"
  executor = "python3"
  script   = "/universe_scripts/elastic_siem/detection_rule.py"
  id_key   = "rule_id"
}

provider "universe" {
  alias = "exception_item"
  executor = "python3"
  script   = "/universe_scripts/elastic_siem/exception_item.py"
  id_key   = "item_id"
}

provider "universe" {
  alias = "exception_container"
  executor = "python3"
  script   = "/universe_scripts/elastic_siem/exception_container.py"
  id_key   = "list_id"
}

provider "universe" {
  alias = "list_container"
  executor = "python3"
  script   = "/universe_scripts/elastic_siem/list_container.py"
  id_key   = "id"
}

provider "universe" {
  alias = "list_item"
  executor = "python3"
  script   = "/universe_scripts/elastic_siem/list_item.py"
  id_key   = "id"
}

