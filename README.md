# Enterprise-Grade Secure GKE Infrastructure on GCP

## 📌 Project Overview
This project demonstrates a production-ready, secure, and multi-tenant Google Kubernetes Engine (GKE) infrastructure deployed entirely via **Terraform**. It is designed to host multiple isolated applications within a Single Cluster using Dedicated Node Pools, Kubernetes Namespaces, and Zero-Trust remote access.

## 🏗️ Architecture Highlights
* **Private GKE Cluster:** Nodes have no public IPs, securing them from the public internet.
* **Network Isolation:** Custom VPC with secondary IP ranges for Pods and Services. Outbound internet access is routed securely through **Cloud NAT**.
* **Multi-Tenancy (Physical & Logical):** Uses dedicated Node Pools with `Taints` and `Tolerations` combined with Kubernetes `Namespaces` to isolate applications (e.g., App1 vs App2).
* **Advanced Security (WAF):** Public access is managed via a Global External Load Balancer protected by **Cloud Armor** (Web Application Firewall).
* **Bastion-less SSH Access:** Secure developer access to private nodes is implemented using **Identity-Aware Proxy (IAP) TCP forwarding** and strict IAM Conditions (Least Privilege), eliminating the need for VPNs or Bastion hosts.
* **CI/CD Ready:** Integrated with **Artifact Registry** and **Workload Identity** for seamless and secure pipeline integrations (e.g., Harness/GitHub Actions).

## 🚀 Technologies Used
* **Cloud Provider:** Google Cloud Platform (GCP)
* **Infrastructure as Code:** Terraform
* **Container Orchestration:** Kubernetes (GKE)
* **Security:** Cloud Armor, IAP, IAM, VPC Firewalls

## 📂 File Structure
* `main.tf`: Core infrastructure (VPC, Subnets, NAT, GKE Cluster, Node Pools).
* `security.tf`: Cloud Armor WAF policies and Global Static IPs.
* `variables.tf`: Configurable variables (Project ID, Region).
* `outputs.tf`: Connection strings and resource names.

## ⚙️ How to Use
1. Clone the repository.
2. Ensure you have authenticated with GCP using `gcloud auth application-default login`.
3. Update the `project_id` in `variables.tf`.
4. Run the following Terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
