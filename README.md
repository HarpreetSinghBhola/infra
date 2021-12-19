# Provision EKS infra using Jenkins 

### Introduction
This repo containing Terraform configuration files to provision Jenkins server, an EKS cluster on AWS. 

#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.0.8 |

```
├── AWS\ Arch\ Diagram.jpeg
├── Jenkinsfile
├── README.md
├── backend-setup
│   ├── backend.tf
│   ├── local.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variables.tf
├── eks
│   ├── backend.tf
│   ├── eks-cluster.tf
│   ├── kubernetes-dashboard-admin.rbac.yaml
│   ├── kubernetes.tf
│   ├── local.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── rbac.tf
│   ├── security-groups.tf
│   ├── vars.tf
│   ├── versions.tf
│   └── vpc.tf
└── jenkins
    └── setup
        ├── backend.tf
        ├── cloudinit.tf
        ├── iam.tf
        ├── init
        │   └── jenkins-init.sh
        ├── instance.tf
        ├── key.tf
        ├── provider.tf
        ├── security_group.tf
        ├── vars.tf
        └── vpc.tf
```
