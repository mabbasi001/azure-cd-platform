# Front Door (global entry point)

Azure Front Door in front of the app tier: global L7 load balancing, TLS, a WAF
policy, per-origin health probes, and **health-based failover** across regions.

Origins are ordered by region — primary first (priority 1), each secondary a warm
standby. Fill them from each region's app-stack outputs:

```
terraform -chdir=../app output -raw backend_hostname
terraform -chdir=../app output -raw frontend_hostname

cp terraform.tfvars.example terraform.tfvars   # edit the origin lists
terraform init
terraform apply
```

Deploy this after the app tier(s) exist. The `infra.yml` `workflow_dispatch`
(`stack = frontdoor`) wires the dev app hostnames in automatically.

The OWASP managed WAF rule set needs the `Premium_AzureFrontDoor` SKU; the default
`Standard_AzureFrontDoor` keeps the custom rate-limit rule only.
