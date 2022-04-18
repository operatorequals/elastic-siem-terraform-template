# elastic-siem-terraform-template
Keeps Elastic SIEM Rules, Exception, Lists as Code

This repository is used for scaffolding Elastic SIEM Rule management with Terraform.
It contains only 1 rule, exception and list.

The repository also provides some Github Workflows that issue `terraform plan` on PR (and comment the results) as well as `terraform apply` on merge.

The Elastic SIEM Rules are preloaded in the repository, under `detection-rules/rules` directory.

## Usage

To use this repository one needs to 
1. Clone it into their account or organization.
2. Use the *Github Secrets* Tab under `Settings` and enter the below Secrets:
* `KIBANA_USERNAME`
* `KIBANA_PASSWORD`
* `KIBANA_URL`
3. (Optional) Create a `state.tf` file defining a [Remote Backend](https://www.terraform.io/language/settings/backends) - If not the Github Workflows will Read/Write the `statefile` through Workflow Artifacts.
4. Run The Github Workflow `Push Rules` using `workflow_dispatch` button, or use `terraform [plan|apply] locally.

## Create New...

### Rule

Under `custom/` one can create an appropriate directory structure and a TOML rule [as defined by Elastic](https://github.com/elastic/detection-rules/tree/main/rules):

```
custom_rules/network/port_scanning.toml
```

The rule will be picked up by Terraform and get deployed.

### Exception for the above Rule

#### Exception Container

Under `exceptions/rules/` one can create a YAML file in a directory structure resembling the Rule's directory structure:

```
exceptions/rules/network/port_scanning.yaml
```

The above YAML file contains the Exception Container fields that are defined by [Elastic API](https://www.elastic.co/guide/en/security/current/exceptions-api-create-container.html). Yet, the `list_id` MUST NOT be populated as it is calculated by `terraform`.

#### Exception Item

Under `exceptions/items/` one can create a YAML file in a directory structure as shown below:

```
exceptions/items/network/port_scanning/internal_scanner.yaml  # The filename can be anything
```

The above YAML file contains the Exception Item fields that are defined by [Elastic API](https://www.elastic.co/guide/en/security/7.17/exceptions-api-create-exception-item.html). Yet, the `list_id` and `item_id` MUST NOT be populated as they are calculated by `terraform`.


https://www.elastic.co/guide/en/security/7.17/exceptions-api-create-exception-item.html

Creating the above files will create the Exception Container and Item in Kibana API and also tie the `port_scanning` Rule with the Exception Container (This happens by `terraform` because ofmatching the directory structure).

### List to be used by an Exception Item

#### List Container

Under `lists/` one can create a YAML file as below:

```
lists/internal_scanners.yaml
```

The above YAML file contains the List Container fields that are defined by [Elastic API](https://www.elastic.co/guide/en/security/current/lists-api-create-container.html). Yet, the `id` field MUST NOT be populated as it is calculated by `terraform`.

#### List Item

Under `list/items/` one can create a YAML files in a directory structure as shown below:

```
lists/items/internal_scanners/qualys.yaml  # The filename can be anything
```

The above YAML file contains the Exception Item fields that are defined by [Elastic API](https://www.elastic.co/guide/en/security/current/lists-api-create-list-item.html). Yet, the `list_id` and `id` MUST NOT be populated as they are calculated by `terraform`, effectively leaving only `value` to be populated.

NOTE: If a list has more than one item (highly probable), several files can be created under `lists/items/<list_name>/<list_item>.yaml`, each populating a single `value` field. There is no other way for Terraform to support lists with this provider.

