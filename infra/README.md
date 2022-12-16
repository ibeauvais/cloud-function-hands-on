This terraform use a bucket on the destination project, to configure it: 

```bash 
export TF_VAR_GCP_PROJECT_ID=xxxx
terraform init -backend-config="bucket="
terraform plan
```
