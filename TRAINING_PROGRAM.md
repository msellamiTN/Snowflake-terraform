# Professional Training Program — Terraform & Snowflake on Azure

> **English companion document.** The authoritative curriculum is the French [`PROGRAMME_FORMATION.md`](PROGRAMME_FORMATION.md). If the two documents diverge, the French document takes precedence.

| Item | Definition |
|---|---|
| **Duration** | 5 days × 6 hours — **30 to 40 hours** |
| **Delivery** | Self-paced autonomous training or instructor-led bootcamp |
| **Practice ratio** | **80% active hands-on labs**, 20% micro-theory |
| **Entry level** | Intermediate IT (DevOps, Data Engineers, SysAdmin, Cloud Architects) |
| **Workstations** | Windows/PowerShell and Linux/macOS/Bash |
| **Core stack** | Terraform, Snowflake Enterprise, Multi-Cloud (Azure, AWS, GCP), Git, CI/CD, dbt |
| **Environments** | DEV, UAT, PROD inside a single Snowflake account |
| **Language** | English and French courseware; official technical terms, HCL code, and CLI syntax in English |

**Mandatory references:** [Academic Master Plan](PLAN.md) · [Reference architecture](docs/reference-architecture.md) · [Version policy](docs/version-policy.md)

## Purpose

Learners build, secure, automate, and operate an enterprise Snowflake platform with Terraform across modern cloud providers (**Microsoft Azure, AWS, or GCP**). They write the project architecture and code step-by-step with automated verification tooling rather than passively reviewing prebuilt repositories.

Key pedagogical pillars include:
- **80% Hands-On Labs**: Atomic, verifiable, copy-pasteable instructions with expected console logs.
- **Continuous Automated Self-Evaluation**: Instant feedback using `SelfPacedLab.ps1` (`Check My Progress`).
- **Tri-Cloud Enterprise Scenarios**: Full options for Azure (ADLS Gen2, Key Vault), AWS (S3, Secrets Manager, KMS), or GCP (GCS, Secret Manager).
- **Chaos Engineering Labs**: Intentional failure injections (manual drift, state lock conflicts, 403 authorization failures) and step-by-step runbooks.
- **FinOps & Security By Design**: Auto-suspending warehouses, passwordless key-pair JWT service users, sub-$0.05 cost per lab.

## Target environment & Tri-Cloud Architecture

| Architecture Layer | 🔵 Microsoft Azure | 🟠 Amazon Web Services (AWS) | 🟢 Google Cloud Platform (GCP) |
|---|---|---|---|
| **Data Cloud** | Snowflake Enterprise | Snowflake Enterprise | Snowflake Enterprise |
| **Infrastructure as Code** | Terraform (`snowflake`, `azurerm`) | Terraform (`snowflake`, `aws`) | Terraform (`snowflake`, `google`) |
| **Remote State Backend** | Azure Blob Storage + Lease Lock | AWS S3 Bucket + DynamoDB Table | Google Cloud Storage + Native Lock |
| **Secret & Key Vault** | Azure Key Vault | AWS Secrets Manager / KMS | GCP Secret Manager / Cloud KMS |
| **External Stages** | Azure Data Lake Storage Gen2 | Amazon S3 Bucket | Google Cloud Storage Bucket |
| **IAM Integration** | Storage Integration (Entra ID SP) | Storage Integration (IAM Role & Ext ID) | Storage Integration (GCP Service Account) |
| **Event-driven Ingestion** | Azure Event Grid + Storage Queue | S3 Notifications + SQS | GCP Pub/Sub Topic & Subscription |
| **CI/CD & GitOps** | Azure DevOps Pipelines / GitHub Actions | GitHub Actions / AWS CodePipeline | GitHub Actions / GitLab CI / Cloud Build |
| **Transformation & FinOps** | dbt Core on `ACCOUNT_USAGE` | dbt Core on `ACCOUNT_USAGE` | dbt Core on `ACCOUNT_USAGE` |
| **Zero-Cost Local Sandbox**| **Azurite** Emulator | **LocalStack** / **MinIO** Emulator | **GCS Local** / **MinIO** Emulator |

## Required access

| Access | Purpose |
|---|---|
| Snowflake Enterprise account | Platform objects |
| Unique learner prefix | Isolation between participants |
| Azure subscription | Backend, Key Vault, storage |
| Azure DevOps project | Pipelines and approvals |

## Professional outcomes

By the end of the course, learners can:

1. prepare and troubleshoot a Terraform/Snowflake workstation on Windows or Unix;
2. create a structured Terraform project from scratch;
3. run and explain `fmt → init → validate → plan → apply`;
4. inspect, protect, and migrate state to Azure Blob Storage;
5. import existing resources and remediate drift;
6. design reusable modules and isolate DEV, UAT, and PROD;
7. automate Snowflake platform objects and cost controls;
8. implement and verify least-privilege RBAC;
9. move from a bootstrap PAT to a service identity with key-pair JWT stored in Key Vault;
10. provision ingestion components against Azure Data Lake Storage;
11. build an Azure DevOps pipeline with validation, plan, approval, apply, and drift detection;
12. produce FinOps evidence with `ACCOUNT_USAGE` and dbt;
13. publish a governed Data Product;
14. demonstrate an idempotent, documented, and cleanable platform;
15. diagnose and remediate production incidents (drift, lock contention, IAM failures).

## Professional Certification Alignment

| Certification Authority | Certification Title | Exam Topics Covered in Curriculum | Aligned Modules |
|---|---|---|---|
| **HashiCorp** | **Terraform Associate (003)** | HCL Syntax, Terraform Workflow, Remote State & Locking, Modules, Dynamic Blocks, Import & Drift | M01, M02, M03, M04, M05, M06, M08 |
| **Snowflake** | **SnowPro Core (COF-C02)** | Virtual Warehouses, Resource Monitors, Databases, Schemas, Stages, COPY INTO, RBAC | M01, M09, M10, M11, M13 |
| **Snowflake** | **SnowPro Advanced Architect** | Storage Integrations, Data Governance, Object Tagging, Multi-Cluster Warehouses, FinOps | M09, M11, M12, M13, M14 |
| **Microsoft** | **Azure DevOps Engineer (AZ-400)** | Infrastructure as Code CI/CD, Workload Identity Federation, Service Connections, Quality Gates | M07, M10, M12 |
| **Amazon Web Services** | **AWS Data Engineer (DEA-C01)** | S3 Storage Ingestion, IAM Roles / External ID, Event-driven Pipelines, KMS Encryption | M02, M09, M10 |
| **Google Cloud** | **Associate Cloud Engineer (ACE)** | Google Cloud Storage, Cloud IAM, Service Accounts, Workload Identity Pools | M02, M09, M10 |

## Isolation and security model

Objects follow `<LEARNER_PREFIX>_<ZONE>_<ENVIRONMENT>`, for example `ABC_RAW_DEV`. The prefix prevents collisions between participants; the suffix reproduces production isolation.

| Stage | Authentication |
|---|---|
| Day 0 to Day 3 | Temporary PAT through a Snowflake CLI profile |
| Day 4 onward | Service identity with key-pair JWT, private key in Key Vault |
| CI/CD | Azure federated identity and pipeline secrets |

No Snowflake password, PAT, private key, or state file is ever committed.

## Five-day outline

### Day 1 — Prepare, create, and deploy (6 hours)

Orientation and security rules, Windows/Unix preflight, Snowflake access with a learner prefix, first Terraform project written file by file, full workflow execution, evidence, and controlled cleanup.

**Evidence:** a learner-authored configuration deploys a database, schema, and cost-controlled warehouse; the second plan reports no unexpected change.

### Day 2 — State, Azure backend, and controlled change (6 hours)

Local state inspection, migration to Azure Blob Storage with locking, variables and naming conventions, dynamic logic, brownfield import, deliberate drift and remediation, idempotence challenge.

**Evidence:** remote state is encrypted and locked, an existing object is imported without recreation, drift is remediated intentionally.

### Day 3 — Modules and DEV/UAT/PROD (6 hours)

Module contract, Landing Zone module built from scratch, data layers with collections, isolated DEV and UAT roots, promotion path to PROD, quality and immutable module sources, extension challenge.

**Evidence:** a reusable module produces isolated, validated environments with no hard-coded environment name.

### Day 4 — Security, RBAC, and service identity (6 hours)

Snowflake privilege model, RBAC as code, current and future grants, service identity with key-pair JWT and Key Vault storage, Azure Data Lake ingestion components, controlled incidents, least-privilege challenge.

**Evidence:** users can perform only allowed actions, credentials stay outside Git, daily work does not rely on an administrative role.

### Day 5 — CI/CD, FinOps, Data Products, capstone (6 hours)

Azure DevOps pipeline with validation, plan, approval gate, apply, and drift audit; policy as code; FinOps with resource monitors and dbt; governed Data Products; independent capstone; demonstration and cleanup.

**Evidence:** CI blocks non-compliant code, FinOps evidence is interpreted, the capstone reaches the pass mark, and the final plan shows no drift.

## Assessment

| Component | Weight |
|---|---:|
| Automated module checkpoints | 30% |
| Functional evidence | 25% |
| Daily challenges | 20% |
| Capstone and demonstration | 25% |

Pass mark: **75%**. An exposed secret or unresolved security control must be fixed before completion.

## Definition of ready

The course is publication-ready only when all 30 hours have been piloted, every objective has an activity and evidence, all labs run from a clean workspace on Windows and Unix, tool versions match the version policy, DEV/UAT/PROD are consistent everywhere, the Azure DevOps pipeline runs, `dbt deps` and `dbt build` succeed, no secret or generated artifact is distributed, and no real account identifier appears in any material.
