# Evolvia Forge

## Overview

Welcome to **Evolvia Forge**. This repository serves as the centralized Infrastructure as Code (IaC) library for the Evolvia project. It utilizes **Terraform** to automate the provisioning, configuration, and management of cloud infrastructure across both **Amazon Web Services (AWS)** and **Microsoft Azure**.

The primary goal of this repository is to provide reusable, standardized infrastructure components and pre-configured environments (labs) to accelerate development, testing, and deployment processes.

## Repository Structure

The repository is organized by cloud provider to ensure clear separation of concerns:

### AWS (`/aws`)
- **`modules/`**: Contains reusable Terraform modules specific to AWS resources. These modules abstract complex configurations into simple, configurable blocks.
- **`labs/`**: Contains root Terraform configurations that act as complete environments or examples. These labs utilize the AWS modules to provision specific architectural setups.

### Azure (`/azure`)
- **`modules/`**: Houses reusable Terraform modules for Azure resources such as Virtual Networks (VNet), Web Apps, SQL databases, AI services, and Storage Accounts.
- **`labs/`**: Provides ready-to-deploy environments (e.g., `basic`, `vm-linux`, `webapp-node`) that instantiate combinations of the Azure modules for various use cases.
- **`files/`**: Contains static configuration files (like JSON files for Network Security Group rules) that are referenced by the modules.
- **`utils/`**: Contains utility scripts and helper files to support the infrastructure lifecycle.

## How It Works

Evolvia Forge is built on the principles of modularity and reusability:

1. **Modular Design**: Instead of writing monolithic Terraform code, resources are localized into independent modules (`/modules`). Each module serves a specific purpose (e.g., creating a Virtual Network or an App Service Plan) and accepts configuration variables.
2. **Environment Instantiation**: The `/labs` directories act as the deployment workspaces (root modules). A lab configuration aggregates multiple modules, passes the necessary variables, and provisions a complete, interconnected environment.
3. **Auxiliary Configurations**: External configurations, such as security rules, are kept in the `/files` directory. Modules can dynamically read these files (e.g., using `jsondecode(file(...))`) to construct resources like Network Security Groups, making the infrastructure highly adaptable without modifying the core module code.

## Prerequisites

To work with the infrastructure defined in this repository, you will need:

- **Terraform**: Installed and configured on your local machine.
- **Cloud Provider CLIs**: 
  - [AWS CLI](https://aws.amazon.com/cli/) for AWS deployments.
  - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) for Azure deployments.
- **Credentials**: Appropriate authentication and active subscriptions/accounts for the target cloud provider.

## Getting Started

1. Navigate to the desired lab environment (e.g., `cd azure/labs/basic`).
2. Initialize the Terraform workspace to download required providers and modules:
   ```bash
   terraform init
   ```
3. Review the execution plan to see the changes that will be made:
   ```bash
   terraform plan
   ```
4. Apply the configuration to provision the infrastructure:
   ```bash
   terraform apply
   ```
