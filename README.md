=======
# Datafold AWS module

This repository provisions resources on AWS, preparing them for a deployment of the
application on an EKS cluster.

## About this module

## Prerequisites

* An AWS account, preferably a new isolated one.
* Terraform >= 1.4.6
* A customer contract with Datafold
  * The application does not work without credentials supplied by sales
* Access to our public helm-charts repository

The full deployment will create the following resources:

* AWS VPC
* AWS subnets
* AWS S3 bucket for clickhouse backups
* AWS Application Load Balancer
* AWS ACM certificate
* Three EBS volumes for local data storage
* AWS RDS Postgres database
* An EKS cluster
* Service accounts for the EKS cluster to perform actions outside of its cluster boundary:
  * Provisioning existing EBS volumes
  * Updating load balancer target group to point to specific pods in the cluster
  * Rescaling the nodegroup between 1-2 nodes

## Negative scope

* This module will not provision DNS names in your zone.

## How to use this module

* See the example for a potential setup, which has dependencies on our helm-charts

Create the bucket and dynamodb table for terraform state file:

* Use the files in `bootstrap` to create a terraform state bucket and a dynamodb lock table.
* Run `./run_bootstrap.sh` to create them. Enter the deployment_name when the question is asked.
  * The `deployment_name` is important. This is used for the k8s namespace and datadog unified logging tags and other places.
  * Suggestion: `company-datafold`
* Transfer the name of that bucket and table into the `backend.hcl` (symlinked into both infra and application)
* Set the `target_account_profile` and `region` where the bucket / table are stored.
* `backend.hcl` is only about where the terraform state file is located.

The example directory contains a single deployment example, which cleanly separates the 
underlying runtime infra from the application deployment into kubernetes. Some specific
elements from the `infra` directory are copied and encrypted into the `application` directory.

Setting up the infrastructure:

* It is easiest if you have full admin access in the target project.
* Pre-create the ACM certificate you want to use on AWS and validate it in your DNS.
* Pre-create a symmetric encryption key that is used to encrypt/decrypt secrets of this deployment.
  * Use the alias instead of the `mrk` link. Put that into `locals.tf`
* Refer to that certificate in main.tf using it's domain name: (Replace "datafold.acme.com")
* Change the settings in locals.tf (the versions in infra and application are sym-linked)
  * provider_region = which region you want to deploy in.
  * aws_profile = The profile you want to use to issue the deployments. Targets the deployment account.
  * kms_profile = Can be the same profile, unless you want the encryption key elsewhere.
  * kms_key = A pre-created symmetric KMS key. It's only purpose is for encryption/decryption of deployment secrets.
  * deployment_name = The name of the deployment, used in kubernetes namespace, container naming and datadog "deployment" Unified Tag)
* Run `terraform init -backend-config=../backend.hcl` in both application and infra directory.
* Our team will reach out to give you two secrets files:
  * `application_secrets.yaml` goes into the `application` directory.
  * `infra_secrets.yaml` goes into the `infra` directory.
  * Encrypt both files with sops and call both `secrets.yaml`
* Run `terraform apply` in `infra` directory. This should complete ok. 
  * Check in the console if you see the load balancer, the EKS cluster, etc.
* Run `terraform apply` in `application` directory.
  * Check the settings made in the `main.tf` file. Maybe you want to set "datadog.install" to `false`. 
  * Check with your favourite kubernetes tool if you see the namespace and several datafold pods running there.

## About subnets and where they get created

The module by default deploys in two availability zones. This is because by default, the subnets
for private and public CIDR ranges have a list of two cidr ranges specified.

The AZ in which things get deployed depends on which AZ's get selected and in which order. This is an
alphabetical ordering. In us-east this could be as many as 6 AZ's.

What the module does is sort the AZs and then it will iteratively deploy a public / private subnet specifying
it's AZ in the module. Thus:

- [10.0.0.0/24] will get deployed in us-east-1a
- [10.0.1.0/24] will get deployed in us-east-1b

To deploy to three AZ's, you should override the public/private subnet settings. Then it will iterate across
3 elements, but the order of the AZ's will be the same by default.

You can add an "exclusion list" to the AZ ID's. The AZ ID is not the same as the AZ name. The AZ name on AWS
is shuffled between their actual location across all AWS accounts. This means that your us-east-1a might be
use1-az1 for you, but it might be use1-az4 for an account elsewhere. So if you need to match AZ's, you should
match Availability zone ID's, not Availability zone names. The AZ ID is visible in the EC2 screen in the 
"settings" screen. There you see a list of enabled AZ's, their ID and their name.

To specifically select particular AZ ID's, exclude the ones you do not want in the az_id_exclude_filter. 
This is a list. That way, you can restrict this to only AZ's you want. Unfortunately it is an exclude filter
and not an include filter. That means if AWS adds additional AZ's, it could create replacements for a future AZ.

Good news is that when there letters in use, I'd expect those letters to be maintained per AZ ID once they exist.
Just for new accounts these can be shuffled all over again. So from terraform state perspective, things should
be consistent at least.

### Initializing the application

Herea are the steps to initialize databases and the initial site settings:

Establish a shell into the `<deployment>-dfshell` container. 
It is likely that the scheduler and server containers are crashing in a loop.

All we need to is to run these commands:

1. `./manage.py clickhouse create-tables`
2. `./manage.py database create-or-upgrade`
3. `./manage.py installation set-new-deployment-params`

Now all containers should be up and running.

### Upgrading to 1.15+

In this version the terraform providers were upgraded to newer versions and this introduces
role name changes and a lot of other things. This means that after the upgrade, you can expect
issues with certain kube-system pods in a crashloop. 

The reason this happens is that the role names have changed that infra creates. They're using a 
prefix and a suffix now.

AWS authenticates the service accounts for certain kube-system pods like aws-loadbalancer-controller,
but after this change that role mapping breaks.

There are ways to fix that manually:
* Apply the application again after applying the infra. This should fix the role names for two pods.
* Go to the service account of the aws-load-balancer-controller pod.
* The service account has a forward mapping to the role ARN they need to assume on the cloud in the annotations
* Update that annotation.

Example:

```yaml
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::1234567889:role/datafold-lb-controller-2025082013431968900000001  <-- This role ARN should correspond to the role.
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
```

Check kubernetes for any failing pods in the kube-system namespace, possibly these need updating in the same
way if the pods continue in the crashloop backoff phase.

* In the newest version of Amazon Linux 3, Datadog cannot determine the local hostname, which it needs for tagging. Updating to the most recent datadog operator solves this issue:

```bash
> helm repo add datadog https://helm.datadoghq.com
> helm repo udpate datadog
> helm update datafold-datadog-operator datadog/datadog-operator
```

* The default version of kubernetes is now 1.33. Nodes will be replaced if you execute this upgrade.
* The AWS LB controller must make calls to the metadata servers. But doing this from a pod means that the hop limit that is in place
  needs to be increased to 2. This avoids having explicit VPC ID's or regions in the configuration of the LB controller, but comes at a 
  limited security impact: 

https://aws.amazon.com/blogs/security/defense-in-depth-open-firewalls-reverse-proxies-ssrf-vulnerabilities-ec2-instance-metadata-service/

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html#imds-considerations

## More information

You can get more information from our documentation site:

https://docs.datafold.com/datafold-deployment/dedicated-cloud/aws


<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.8.0 |
| <a name="requirement_dns"></a> [dns](#requirement\_dns) | 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.8.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_clickhouse_backup"></a> [clickhouse\_backup](#module\_clickhouse\_backup) | ./modules/clickhouse_backup | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ./modules/eks | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ./modules/load_balancer | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_certificate_domain"></a> [alb\_certificate\_domain](#input\_alb\_certificate\_domain) | Pass a domain name like example.com to this variable in order to enable ALB HTTPS listeners.<br>Terraform will try to find AWS certificate that is issued and matches asked domain,<br>so please make sure that you have issued a certificate for asked domain already. | `string` | n/a | yes |
| <a name="input_apply_major_upgrade"></a> [apply\_major\_upgrade](#input\_apply\_major\_upgrade) | Sets the flag to allow AWS to apply major upgrade on the maintenance plan schedule. | `bool` | `false` | no |
| <a name="input_aws_auth_accounts"></a> [aws\_auth\_accounts](#input\_aws\_auth\_accounts) | List of account maps to add to the aws-auth configmap | `list(any)` | `[]` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | List of user maps to add to the aws-auth configmap | `list(any)` | `[]` | no |
| <a name="input_backend_app_port"></a> [backend\_app\_port](#input\_backend\_app\_port) | The target port to use for the backend services | `number` | `80` | no |
| <a name="input_clickhouse_data_size"></a> [clickhouse\_data\_size](#input\_clickhouse\_data\_size) | EBS volume size for clickhouse data in GB | `number` | `40` | no |
| <a name="input_clickhouse_logs_size"></a> [clickhouse\_logs\_size](#input\_clickhouse\_logs\_size) | EBS volume size for clickhouse logs in GB | `number` | `40` | no |
| <a name="input_clickhouse_s3_bucket"></a> [clickhouse\_s3\_bucket](#input\_clickhouse\_s3\_bucket) | Bucket where clickhouse backups are stored | `string` | `"clickhouse-backups-abcguo23"` | no |
| <a name="input_create_aws_auth_configmap"></a> [create\_aws\_auth\_configmap](#input\_create\_aws\_auth\_configmap) | Whether to create the AWS authentication configmap | `bool` | `false` | no |
| <a name="input_create_rds_kms_key"></a> [create\_rds\_kms\_key](#input\_create\_rds\_kms\_key) | Set to true to create a separate KMS key (Recommended). | `bool` | `true` | no |
| <a name="input_create_ssl_cert"></a> [create\_ssl\_cert](#input\_create\_ssl\_cert) | Creates an SSL certificate is set. | `bool` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | RDS database name | `string` | `"datafold"` | no |
| <a name="input_db_instance_tags"></a> [db\_instance\_tags](#input\_db\_instance\_tags) | The extra tags to be applied to the RDS instance. | `map(any)` | `{}` | no |
| <a name="input_db_parameter_group_tags"></a> [db\_parameter\_group\_tags](#input\_db\_parameter\_group\_tags) | The extra tags to be applied to the parameter group | `map(any)` | `{}` | no |
| <a name="input_db_subnet_group_tags"></a> [db\_subnet\_group\_tags](#input\_db\_subnet\_group\_tags) | The extra tags to be applied to the parameter group | `map(any)` | `{}` | no |
| <a name="input_default_node_disk_size"></a> [default\_node\_disk\_size](#input\_default\_node\_disk\_size) | Disk size for a node in GB | `number` | `40` | no |
| <a name="input_deploy_vpc_flow_logs"></a> [deploy\_vpc\_flow\_logs](#input\_deploy\_vpc\_flow\_logs) | Activates the VPC flow logs if set. | `bool` | `false` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name of the current deployment. | `string` | n/a | yes |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | Specifies DNS name for DHCP options set | `string` | `""` | no |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp\_options\_domain\_name\_servers](#input\_dhcp\_options\_domain\_name\_servers) | Specify a list of DNS server addresses for DHCP options set | `list(string)` | <pre>[<br>  "AmazonProvidedDNS"<br>]</pre> | no |
| <a name="input_dhcp_options_tags"></a> [dhcp\_options\_tags](#input\_dhcp\_options\_tags) | Tags applied to the DHCP options set. | `map(string)` | `{}` | no |
| <a name="input_dns_egress_cidrs"></a> [dns\_egress\_cidrs](#input\_dns\_egress\_cidrs) | List of Internet addresses to which the application has access | `list(string)` | `[]` | no |
| <a name="input_ebs_extra_tags"></a> [ebs\_extra\_tags](#input\_ebs\_extra\_tags) | The extra tags to be applied to the EBS volumes | `map(any)` | `{}` | no |
| <a name="input_ebs_iops"></a> [ebs\_iops](#input\_ebs\_iops) | IOPS of EBS volume | `number` | `3000` | no |
| <a name="input_ebs_throughput"></a> [ebs\_throughput](#input\_ebs\_throughput) | Throughput of EBS volume | `number` | `1000` | no |
| <a name="input_ebs_type"></a> [ebs\_type](#input\_ebs\_type) | Type of EBS volume | `string` | `"gp3"` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Flag to use custom DHCP options for DNS resolution. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Global environment tag to apply on all datadog logs, metrics, etc. | `string` | n/a | yes |
| <a name="input_host_override"></a> [host\_override](#input\_host\_override) | Overrides the default domain name used to send links in invite emails and page links. Useful if the application is behind cloudflare for example. | `string` | `""` | no |
| <a name="input_ingress_enable_http_sg"></a> [ingress\_enable\_http\_sg](#input\_ingress\_enable\_http\_sg) | Whether regular HTTP traffic should be allowed to access the load balancer | `bool` | `false` | no |
| <a name="input_k8s_cluster_version"></a> [k8s\_cluster\_version](#input\_k8s\_cluster\_version) | Ref. https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html | `string` | `"1.29"` | no |
| <a name="input_k8s_module_version"></a> [k8s\_module\_version](#input\_k8s\_module\_version) | EKS terraform module version | `string` | `"~> 19.7"` | no |
| <a name="input_lb_idle_timeout"></a> [lb\_idle\_timeout](#input\_lb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `120` | no |
| <a name="input_lb_internal"></a> [lb\_internal](#input\_lb\_internal) | Set to true to make the load balancer internal and not exposed to the internet. | `bool` | `false` | no |
| <a name="input_manage_aws_auth_configmap"></a> [manage\_aws\_auth\_configmap](#input\_manage\_aws\_auth\_configmap) | Determines whether to manage the aws-auth configmap | `bool` | `false` | no |
| <a name="input_managed_node_grp"></a> [managed\_node\_grp](#input\_managed\_node\_grp) | Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group | `any` | n/a | yes |
| <a name="input_managed_node_grp_default"></a> [managed\_node\_grp\_default](#input\_managed\_node\_grp\_default) | Ref. https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt | `list(any)` | `[]` | no |
| <a name="input_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#input\_nat\_gateway\_public\_ip) | Public IP of the NAT gateway when reusing the NAT gateway instead of recreating | `string` | `""` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | The extra tags to be applied to the private subnets | `map(any)` | `{}` | no |
| <a name="input_propagate_intra_route_tables_vgw"></a> [propagate\_intra\_route\_tables\_vgw](#input\_propagate\_intra\_route\_tables\_vgw) | If intra subnets should propagate traffic. | `bool` | `false` | no |
| <a name="input_propagate_private_route_tables_vgw"></a> [propagate\_private\_route\_tables\_vgw](#input\_propagate\_private\_route\_tables\_vgw) | If private subnets should propagate traffic. | `bool` | `false` | no |
| <a name="input_propagate_public_route_tables_vgw"></a> [propagate\_public\_route\_tables\_vgw](#input\_propagate\_public\_route\_tables\_vgw) | If public subnets should propagate traffic. | `bool` | `false` | no |
| <a name="input_provider_azs"></a> [provider\_azs](#input\_provider\_azs) | List of availability zones to consider. If empty, the modules will determine this dynamically. | `list(string)` | `[]` | no |
| <a name="input_provider_region"></a> [provider\_region](#input\_provider\_region) | The AWS region in which the infrastructure should be deployed | `string` | n/a | yes |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | The extra tags to be applied to the public subnets | `map(any)` | `{}` | no |
| <a name="input_rds_allocated_storage"></a> [rds\_allocated\_storage](#input\_rds\_allocated\_storage) | The size of RDS allocated storage in GB | `number` | `20` | no |
| <a name="input_rds_backups_replication_retention_period"></a> [rds\_backups\_replication\_retention\_period](#input\_rds\_backups\_replication\_retention\_period) | RDS backup replication retention period | `number` | `14` | no |
| <a name="input_rds_backups_replication_target_region"></a> [rds\_backups\_replication\_target\_region](#input\_rds\_backups\_replication\_target\_region) | RDS backup replication target region | `string` | `null` | no |
| <a name="input_rds_extra_tags"></a> [rds\_extra\_tags](#input\_rds\_extra\_tags) | The extra tags to be applied to the RDS instance | `map(any)` | `{}` | no |
| <a name="input_rds_instance"></a> [rds\_instance](#input\_rds\_instance) | EC2 insance type for PostgreSQL RDS database.<br>Available instance groups: t3, m4, m5.<br>Available instance classes: medium and higher. | `string` | `"db.t3.medium"` | no |
| <a name="input_rds_kms_key_alias"></a> [rds\_kms\_key\_alias](#input\_rds\_kms\_key\_alias) | RDS KMS key alias. | `string` | `"datafold-rds"` | no |
| <a name="input_rds_max_allocated_storage"></a> [rds\_max\_allocated\_storage](#input\_rds\_max\_allocated\_storage) | The upper limit the database can grow in GB | `number` | `100` | no |
| <a name="input_rds_param_group_family"></a> [rds\_param\_group\_family](#input\_rds\_param\_group\_family) | The DB parameter group family to use | `string` | `"postgres15"` | no |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | Port the RDS database should be listening on. | `number` | `5432` | no |
| <a name="input_rds_ro_username"></a> [rds\_ro\_username](#input\_rds\_ro\_username) | RDS read-only user name (not currently used). | `string` | `"datafold_ro"` | no |
| <a name="input_rds_username"></a> [rds\_username](#input\_rds\_username) | Overrides the default RDS user name that is provisioned. | `string` | `"datafold"` | no |
| <a name="input_rds_version"></a> [rds\_version](#input\_rds\_version) | Postgres RDS version to use. | `string` | `"15.5"` | no |
| <a name="input_redis_data_size"></a> [redis\_data\_size](#input\_redis\_data\_size) | Redis EBS volume size in GB | `number` | `10` | no |
| <a name="input_s3_clickhouse_backup_tags"></a> [s3\_clickhouse\_backup\_tags](#input\_s3\_clickhouse\_backup\_tags) | The extra tags to be applied to the S3 clickhouse backup bucket | `map(any)` | `{}` | no |
| <a name="input_self_managed_node_grp"></a> [self\_managed\_node\_grp](#input\_self\_managed\_node\_grp) | Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/self-managed-node-group | `any` | `{}` | no |
| <a name="input_self_managed_node_grp_default"></a> [self\_managed\_node\_grp\_default](#input\_self\_managed\_node\_grp\_default) | Configuration for the self managed node group | `any` | `{}` | no |
| <a name="input_self_managed_node_grp_instance_type"></a> [self\_managed\_node\_grp\_instance\_type](#input\_self\_managed\_node\_grp\_instance\_type) | Ref. https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt | `string` | `"THe instance type for the self managed node group."` | no |
| <a name="input_sg_tags"></a> [sg\_tags](#input\_sg\_tags) | The extra tags to be applied to the security group | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the general module | `any` | `{}` | no |
| <a name="input_use_default_rds_kms_key"></a> [use\_default\_rds\_kms\_key](#input\_use\_default\_rds\_kms\_key) | Flag weither or not to use the default RDS KMS encryption key. Not recommended. | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR of the new VPC, if the vpc\_cidr is not set | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID of an existing VPC to deploy the cluster in. Creates a new VPC if not set. | `string` | `""` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | The private subnet CIDR ranges when a new VPC is created. | `list(string)` | <pre>[<br>  "10.0.0.0/24",<br>  "10.0.1.0/24"<br>]</pre> | no |
| <a name="input_vpc_propagating_vgws"></a> [vpc\_propagating\_vgws](#input\_vpc\_propagating\_vgws) | ID's of virtual private gateways to propagate. | `list(any)` | `[]` | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | The public network CIDR ranges | `list(string)` | <pre>[<br>  "10.0.100.0/24",<br>  "10.0.101.0/24"<br>]</pre> | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | The extra tags to be applied to the VPC | `map(any)` | `{}` | no |
| <a name="input_vpc_vpn_gateway_id"></a> [vpc\_vpn\_gateway\_id](#input\_vpc\_vpn\_gateway\_id) | ID of the VPN gateway to attach to the VPC | `string` | `""` | no |
| <a name="input_whitelisted_egress_cidrs"></a> [whitelisted\_egress\_cidrs](#input\_whitelisted\_egress\_cidrs) | List of Internet addresses the application can access going outside | `list(string)` | n/a | yes |
| <a name="input_whitelisted_ingress_cidrs"></a> [whitelisted\_ingress\_cidrs](#input\_whitelisted\_ingress\_cidrs) | List of CIDRs that can pass through the load balancer | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clickhouse_access_key"></a> [clickhouse\_access\_key](#output\_clickhouse\_access\_key) | The access key of the IAM user doing the clickhouse backups. |
| <a name="output_clickhouse_data_size"></a> [clickhouse\_data\_size](#output\_clickhouse\_data\_size) | The size in GB of the clickhouse EBS data volume |
| <a name="output_clickhouse_data_volume_id"></a> [clickhouse\_data\_volume\_id](#output\_clickhouse\_data\_volume\_id) | The EBS volume ID where clickhouse data will be stored. |
| <a name="output_clickhouse_logs_size"></a> [clickhouse\_logs\_size](#output\_clickhouse\_logs\_size) | The size in GB of the clickhouse EBS logs volume |
| <a name="output_clickhouse_logs_volume_id"></a> [clickhouse\_logs\_volume\_id](#output\_clickhouse\_logs\_volume\_id) | The EBS volume ID where clickhouse logs will be stored. |
| <a name="output_clickhouse_password"></a> [clickhouse\_password](#output\_clickhouse\_password) | The generated clickhouse password to be used in the application deployment |
| <a name="output_clickhouse_s3_bucket"></a> [clickhouse\_s3\_bucket](#output\_clickhouse\_s3\_bucket) | The location of the S3 bucket where clickhouse backups are stored |
| <a name="output_clickhouse_s3_region"></a> [clickhouse\_s3\_region](#output\_clickhouse\_s3\_region) | The region where the S3 bucket is created |
| <a name="output_clickhouse_secret_key"></a> [clickhouse\_secret\_key](#output\_clickhouse\_secret\_key) | The secret key of the IAM user doing the clickhouse backups. |
| <a name="output_cloud_provider"></a> [cloud\_provider](#output\_cloud\_provider) | A string describing the type of cloud provider to be passed onto the helm charts |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_scaler_role_arn"></a> [cluster\_scaler\_role\_arn](#output\_cluster\_scaler\_role\_arn) | The ARN of the role that is able to scale the EKS cluster nodes. |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The ID of the RDS database instance |
| <a name="output_deployment_name"></a> [deployment\_name](#output\_deployment\_name) | The name of the deployment |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The domain name to be used in DNS configuration |
| <a name="output_k8s_load_balancer_controller_role_arn"></a> [k8s\_load\_balancer\_controller\_role\_arn](#output\_k8s\_load\_balancer\_controller\_role\_arn) | The ARN of the role provisioned so the k8s cluster can edit the target group through the AWS load balancer controller. |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | The name of the external load balancer |
| <a name="output_load_balancer_ips"></a> [load\_balancer\_ips](#output\_load\_balancer\_ips) | The load balancer IP when it was provisioned. |
| <a name="output_postgres_database_name"></a> [postgres\_database\_name](#output\_postgres\_database\_name) | The name of the pre-provisioned database. |
| <a name="output_postgres_host"></a> [postgres\_host](#output\_postgres\_host) | The DNS name for the postgres database |
| <a name="output_postgres_password"></a> [postgres\_password](#output\_postgres\_password) | The generated postgres password to be used by the application |
| <a name="output_postgres_port"></a> [postgres\_port](#output\_postgres\_port) | The port configured for the RDS database |
| <a name="output_postgres_username"></a> [postgres\_username](#output\_postgres\_username) | The postgres username to be used by the application |
| <a name="output_redis_data_size"></a> [redis\_data\_size](#output\_redis\_data\_size) | The size in GB of the Redis data volume. |
| <a name="output_redis_data_volume_id"></a> [redis\_data\_volume\_id](#output\_redis\_data\_volume\_id) | The EBS volume ID of the Redis data volume. |
| <a name="output_redis_password"></a> [redis\_password](#output\_redis\_password) | The generated redis password to be used in the application deployment |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group ID managing ingress from the load balancer |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | The ARN to the target group where the pods need to be registered as targets. |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | The CIDR of the entire VPC |

<!-- END_TF_DOCS -->

