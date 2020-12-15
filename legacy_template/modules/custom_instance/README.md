## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| animal\_names | List of animal names to assign to the instances | `list` | `[]` | no |
| count | Number of Linux EC2 instances to create | `number` | `1` | no |
| custom\_install\_scripts | List of rendered Bash scripts to customise your VMs with. Should be a list in case we deploy multiple instances | `list` | `[]` | no |
| default\_security\_group\_id | ID of default security group in the vpc | `any` | n/a | yes |
| instance\_type | EC2 Instance type to use for the training instances | `string` | `"t2.micro"` | no |
| ssh\_key\_name | SSH key name to be used for the instances. If not specified it'll be generated | `string` | `""` | no |
| ssh\_password | Limited SSH user's password | `string` | `"PeoplesComputers1"` | no |
| ssh\_user | Limited SSH user account | `string` | `"playground"` | no |
| stack\_name | Prefix for the instance names | `any` | n/a | yes |
| subnet\_ids | List of Subnet IDs to put the instances into | `list` | `[]` | no |
| vpc\_id | VPC to put the instances into | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ip\_addresses | List of IP addresses for the linux instances |

