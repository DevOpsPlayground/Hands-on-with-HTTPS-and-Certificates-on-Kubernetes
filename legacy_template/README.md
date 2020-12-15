# Legacy tf template for playground workstations
It is still messy, and not well documented, but it is something right? :) 
Few considerations:
1. The code is written in Terraform 11.14
2. The userdata  template is rendered from two files:
     
     a. Base script (Wetty, Nginx, basic config) -  `./modules/custom_instance/scripts`
     
     b. User script (workshops specific shell script, vaires between the playground + Docker and IDE as container which probably would be better within base script) - `./scripts`
     
3. For the base image we are using AWS provided Ubuntu Bionic (18.04)
4. For the DNS records we are using existing Route53 hosted zones - we can create them and attach to azure instances if we can get array of public IP adresses.
