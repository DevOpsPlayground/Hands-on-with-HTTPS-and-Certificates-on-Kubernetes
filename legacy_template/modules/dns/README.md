# DPG - DNS module

This module assigns a list of IP addresses with a list of animal names on the specified domain.

The `devopsplayground.com` and `ecsd.training` domains are hosted by Route 53 in our **`ecsd-training`** AWS account.

Zone IDs:

| TLD | Route53 Zone ID |
|-----|-----------------|
|devopsplayground.com | ZHQ86ZHWMXO1D |
|ldn.devopsplayground.com | ZKL6DCZ2ESZ63 |
|edi.devopsplayground.com | Z32QV07KBPOOPC |
|sin.devopsplayground.com | Z16VLI9W6DLJ7G |
|ecsd.training | Z2YSGFKC3LJZBA |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| animal\_names | List of animal names the domains to be created from | list | `<list>` | no |
| count | Number of dns records to be created | string | n/a | yes |
| ip\_addresses | List of IP addresses to assign to animal names | list | `<list>` | no |
| r53\_zone\_id | AWS Route53 Zone ID for the hosted domain we're using | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| fqdns | List of Fully Qualified Domain Names for the Playground attendees. |

