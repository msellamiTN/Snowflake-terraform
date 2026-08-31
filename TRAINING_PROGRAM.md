# Professional Training Program — Terraform & Snowflake on Azure

> **English companion document.** The authoritative curriculum is the French [`PROGRAMME_FORMATION.md`](PROGRAMME_FORMATION.md). If the two documents diverge, the French document takes precedence.

| Item | Definition |
|---|---|
| **Duration** | 5 days × 6 hours — **30 hours** |
| **Delivery** | Instructor-led or guided self-paced learning |
| **Practice ratio** | 65–70%, on a project built from an almost empty workspace |
| **Entry level** | Intermediate IT |
| **Workstations** | Windows/PowerShell and Linux/macOS/Bash |
| **Core stack** | Terraform, Snowflake Enterprise, Azure, Azure DevOps, Git, Snowflake CLI, dbt |
| **Environments** | DEV, UAT, PROD inside a single Snowflake account |
| **Language** | French learning content; official English technical terms and commands |

**Mandatory references:** [Reference architecture](docs/reference-architecture.md) · [Version policy](docs/version-policy.md)

## Purpose

Learners build, secure, automate, and operate a Snowflake platform with Terraform on Azure, reproducing the company's real environment. They create the project structure and code one file at a time instead of inspecting a prebuilt solution. Every important action includes an expected result, a validation checkpoint, and a recovery path.

## Target environment

| Layer | Technology |
|---|---|
| Data cloud | Snowflake Enterprise, single account |
| Isolation | `DEV`, `UAT`, `PROD` naming convention |
| Infrastructure as Code | Terraform |
| Remote state | Azure Blob Storage |
| Secrets | Azure Key Vault |
| CI/CD | Azure DevOps with self-hosted agents |
| Storage and ingestion | Azure Data Lake Storage Gen2 |
| Transformation and FinOps | dbt on `ACCOUNT_USAGE` |

AWS and GCP appear only as a comparison appendix, with no executable lab.

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
14. demonstrate an idempotent, documented, and cleanable platform.

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
