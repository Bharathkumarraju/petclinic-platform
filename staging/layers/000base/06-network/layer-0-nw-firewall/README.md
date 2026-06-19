# Create Network Firewall

1. Use [create-policy-and-rule-groups](https://github.com/abaxxsingapore/abex-aws-tf-modules/tree/network-firewall/modules/network-firewall/create-policy-and-rule-groups) module to Create Network Firewall Policy and Rule Groups.
2. Use [create-network-firewall-only](https://github.com/abaxxsingapore/abex-aws-tf-modules/tree/network-firewall/modules/network-firewall/create-network-firewall-only) module to create Network Firewall and attach the Network Firewall Policy ARN using the input `firewall_policy_arn`

## Deployment Notes

### 1. Create Network Firewall Rules in repo abex-aws-cross-network-firewall-rules
  - create new branch 
  - copy working directory (aws-pre-prod) to new one aws-uat
  - delete .terraform*
  - update the ff files:
    - `backend.tf` with correct/new key
    - `locals.tf` with correct default_account_arn, env and public cidr tf state

### 2. Create Firewall Subnets and Route Tables
  - Create new branch for the env repo
  - git clone git@github.com:abaxxsingapore/abex-aws-env-uat.git
  - git branch feature/add-network-firewall 
  - git checkout feature/add-network-firewall
  - update `layers/000base/06-network/layer-0/network.tf` and add the ff:

```
aws_firewall_subnets          = cidrsubnets(cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 6, 32), 2, 2, 2)
aws_firewall_subnet_names     = ["${local.env}-main-sin-firewall-${local.region_map["sin"]}a", "${local.env}-main-sin-firewall-${local.region_map["sin"]}b", "${local.env}-main-sin-firewall-${local.region_map["sin"]}c"]
aws_firewall_route_table_name = "${local.env}-main-sin-firewall"
```

  - update `layers/000base/06-network/layer-0/main.tf` and add the ff:

```
# Create Firewall Subnets
resource "aws_subnet" "firewall_subnet" {
  count             = length(local.subnet_map["sin"]["aws_firewall_subnet_names"])
  vpc_id            = module.main_vpc_sin.vpc_id
  availability_zone = local.subnet_map["sin"]["aws_azs"][count.index]
  cidr_block        = local.subnet_map["sin"]["aws_firewall_subnets"][count.index]
  tags = {
    Name    = local.subnet_map["sin"]["aws_firewall_subnet_names"][count.index]
    env     = local.env
    Purpose = "Firewall Ext Subnets"
  }
}

# Create Route Table for Firewall Subnets
resource "aws_route_table" "firewall_route_table" {
  vpc_id = module.main_vpc_sin.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.main_vpc_sin.igw_id
  }

  tags = {
    Name = local.subnet_map["sin"]["aws_firewall_route_table_name"]
  }
}

# Route Table Association with Firewall Subnets
resource "aws_route_table_association" "firewall_route_table_association" {
  count          = length(local.subnet_map["sin"]["aws_firewall_subnet_names"])
  subnet_id      = element(aws_subnet.firewall_subnet.*.id, count.index)
  route_table_id = aws_route_table.firewall_route_table.id
}
```

  - `update layers/000base/06-network/layer-0/outputs.tf` and add the ff:

```
output "main_vpc_firewall_route_table_ids_sin" {
  description = "List of ID of firewall route tables"
  value       = aws_route_table.firewall_route_table.id
}

output "main_vpc_firewall_subnets_sin" {
  description = "List of IDs of firewall subnets"
  value       = aws_subnet.firewall_subnet.*.id
}
```

### 3. Manually remove Public Subnets association in the Public Route Table in AWS console
- the error below will be enountered if association is not removed.
```
│ Error: error creating Route Table (rtb-06f6dd69db5ed69ae) Association: Resource.AlreadyAssociated: the specified association for route table rtb-06f6dd69db5ed69ae conflicts with an existing association
│       status code: 400, request id: 246446b7-0253-4154-a245-0265741f8eb0
│ 
│   with aws_route_table_association.public_subnets_to_nfw[1],
│   on nfw_routing.tf line 55, in resource "aws_route_table_association" "public_subnets_to_nfw":
│   55: resource "aws_route_table_association" "public_subnets_to_nfw" {
```

### 4. Copy/Create layer to deploy Network Firewall
  - copy layers/000base/06-network/layer-0-nw-firewall from pre-prod repo
  - delete .terraform*
  - `backend.tf` with correct key
  - `shared_remote.tf` with correct network-firewall-rules remote state
  - `main.tf` change to correct `firewall_policy_arn`
  - For UAT, deploy NFW only to a Single subnet
    - define only one subnet in `subnet_mapping`
    - update `nfw_endpoint_id_list` in `nfw_locals.tf` to have only 1 endpoint for the list

    ```
    # NFW Endpoint ID List
    #nfw_endpoint_id_list = [module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1b, module.network_firewall.endpoint_id_az.ap-southeast-1c]
    nfw_endpoint_id_list = [module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1a]
    ```

### 5. Add routes to transit gateway for the public subnet route tables 

  - update `layers/000base/06-network/layer-transit-gw/main.tf` and add the ff:

```
  # Added for Network Firewall
data "aws_route_table" "nfw_public_route_tables" {
  count          = length(local.nfw_public_route_tables)
  route_table_id = local.nfw_public_route_tables[count.index]
}

resource "aws_route" "nfw_route_nw_public" {
  count                  = length(data.aws_route_table.nfw_public_route_tables)
  route_table_id         = data.aws_route_table.nfw_public_route_tables[count.index].id
  destination_cidr_block = local.aws_network_vpc_cidr_range
  transit_gateway_id     = local.transit_gw_id_sin
}
```

-  Update `layers/000base/06-network/layer-transit-gw/network_layer_tgw.tf` and add the ff:

```
  # Added for Network Firewall
  nfw_public_route_tables = data.terraform_remote_state.network-firewall.outputs.public_route_table_ids
```

- Update `layers/000base/06-network/layer-transit-gw/shared_remote.tf`  and add the ff:

```
  # Added for Network Firewall
data "terraform_remote_state" "network-firewall" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/${local.env}/base/network/layer-nw-firewall"
    region = "ap-southeast-1"
  }
}
```