
/*
  Paths for TOML and YAML files
*/
locals{
  elastic_rule_dir = "${path.module}/detection-rules/rules"
  custom_rule_dir = "${path.module}/custom"

  exception_dir = "${path.module}/exceptions"
  exception_container_dir = "${local.exception_dir}/rules"
  exception_item_dir = "${local.exception_dir}/items"

  list_dir = "${path.module}/lists"
  list_item_dir = "${local.list_dir}/items"
}

// ================== Rules ==================
/* 
  Terraform Resource that creates Elastic Rules from TOMLs
*/
resource "universe" "rules_elastic" {
  provider = universe.detection_rule
  for_each = fileset(local.elastic_rule_dir, "**/**.toml")

  config   =<<CONFIG
${file("${local.elastic_rule_dir}/${each.key}")}

%{ if fileexists("${local.exception_container_dir}/${split(".", each.key)[0]}.yaml") }

# Add an Exception Container to each rule
[[rule.exceptions_list]]
id = "${replace(split(".",each.key)[0], "/", "-")}"
list_id = "${replace(split(".",each.key)[0], "/", "-")}"
namespace_type = "single"
type = "detection"
%{ endif }

CONFIG

  depends_on = [universe.exceptions, universe.exception_items]
}

/* 
  Terraform Resource that creates Custom Rules from TOMLs
*/
resource "universe" "rules_custom" {
  provider = universe.detection_rule
  for_each = fileset(local.custom_rule_dir, "**/**.toml")

  config   =<<CONFIG
${file("${local.custom_rule_dir}/${each.key}")}

%{ if fileexists("${local.exception_container_dir}/${split(".", each.key)[0]}.yaml") }

# Add an Exception Container to each rule
[[rule.exceptions_list]]
id = "${replace(split(".",each.key)[0], "/", "-")}"
list_id = "${replace(split(".",each.key)[0], "/", "-")}"
namespace_type = "single"
type = "detection"
%{ endif }

CONFIG

  depends_on = [universe.exceptions, universe.exception_items]
}


// ================== Exceptions ==================
/* 
  Terraform Resource that creates Exception Containers
  using the filepath to generate their IDs
*/
resource "universe" "exceptions" {
  provider = universe.exception_container
  for_each = fileset(local.exception_container_dir, "**/**.yaml")

  config   =<<CONFIG
list_id: "${replace(split(".",each.key)[0], "/", "-")}"
${file("${local.exception_container_dir}/${each.key}")}
CONFIG
}

/* 
  Terraform Resource that creates Exception Items
  and matches them with Exception Containers based on filepaths
*/
resource "universe" "exception_items" {
  provider = universe.exception_item
  for_each = fileset(local.exception_item_dir, "**/**.yaml")

   config   =<<CONFIG
item_id: "${replace(split(".",each.key)[0], "/", "-")}"
list_id: "${join("-", slice(split("/", each.key), 0, length(split("/", each.key))-1))}"
${file("${local.exception_item_dir}/${each.key}")}
CONFIG

  depends_on = [universe.exceptions, universe.lists]
}


// ================== Lists ==================

/* 
  Terraform Resource that creates List Containers
  using the filepath to generate their IDs
*/
resource "universe" "lists" {
  provider = universe.list_container
  for_each = fileset(local.list_dir, "**.yaml")

  config   =<<CONFIG
id: "${replace(split(".",each.key)[0], "/", "-")}"

${file("${local.list_dir}/${each.key}")}
CONFIG
}

/* 
  Terraform Resource that creates List Items
  and matches them with Exception Containers based on filepaths
*/
resource "universe" "list_items" {
  provider = universe.list_item
  for_each = fileset(local.list_item_dir, "**/**.yaml")

  config   =<<CONFIG
id: "${replace(split(".",each.key)[0], "/", "-")}"
list_id: "${join("-", slice(split("/", each.key), 0, length(split("/", each.key))-1))}"

${file("${local.list_item_dir}/${each.key}")}
CONFIG

  depends_on = [universe.lists]
}

