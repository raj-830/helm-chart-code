# GKE OCI Helm Deployment Module

This Terraform module facilitates the secure, automated deployment of Helm charts hosted as OCI images inside Google Artifact Registry to a Google Kubernetes Engine (GKE) cluster. It operates natively with Application Default Credentials (ADC), bypassing the need for third-party command-line utilities or local shell provisioners.

## Input Variables Reference

The table below describes all input variables required or supported by this module.

| Variable Name | Type | Description | Default | Required |
| :--- | :---: | :--- | :---: | :---: |
| `gcp_project_id` | `string` | The target Google Cloud Platform (GCP) Project ID. | *None* | **Yes** |
| `cluster_id` | `string` | The shorthand resource name or ID of the target GKE cluster (e.g., `pvt-gke`). | *None* | **Yes** |
| `cluster_endpoint` | `string` | The internal control plane DNS endpoint string (`*.gke.goog`) for the cluster. | *None* | **Yes** |
| `set_inputs` | `string` | Comma-separated list of key-value overrides passed to the Helm execution engine (Format: `key1:val1,key2:val2`). | *None* | **Yes** |
| `cluster_ca_certificate` | `string` | The raw, un-decoded base64 cluster CA certificate string. | `""` | No |
| `insecure_connection` | `bool` | Whether to bypass strict server TLS verification (crucial for Bastion/Private VPC runners). | `false` | No |
| `repository_link` | `string` | **[Public Chart Routing]** Pass the HTTP repository link. If any value is passed here, it automatically takes priority over `artifact_registry_repo_name` and directs the deployment to a public repo. Leave empty/null to deploy a private chart. | `null` | No |
| `artifact_registry_repo_name` | `string` | **[Private Chart Routing]** The name of the Google Artifact Registry repository hosting your private OCI Helm charts. To use this, you must have an OCI image pushed inside the registry and leave `repository_link` completely empty. | `"oci-images"` | No |
| `gcp_region` | `string` | The regional location of the Google Artifact Registry repository and GKE cluster. | `"us-central1"` | No |
| `gcp_zone` | `string` | The specific GCP availability zone where the GKE cluster resides. | `"us-central1"` | No |
| `helm_namespace` | `string` | The target Kubernetes namespace inside GKE where resources will be installed. | `"velero"` | No |
| `chart` | `string` | The exact name of the OCI chart artifact inside the registry. | `"velero"` | No |

---

## Detailed Variable Breakdown

### `gcp_project_id` (Required)
The unique project identifier within Google Cloud. This project must host both the target GKE cluster and the Google Artifact Registry repository containing your containerized charts.

### `cluster_id` (Required)
The name string of your target cluster (e.g., `pvt-gke`). Used internally by the module's local configurations to handle naming schema derivations.

### `cluster_endpoint` (Required)
The fully qualified DNS address pointing to the private master control plane of the GKE instance.
* **Example Format:** `gke-48d9a416e1734b6e856740e1362632c46594-128750651080.us-central1.gke.goog`

### `insecure_connection` (Optional)
When working behind strict corporate proxies, a dedicated bastion host, or private automation pipelines (like **Cloud Build Private Worker Pools**), setting this flag to `true` allows the underlying Go client to skip strict x509 public authority verification chains when talking over local VPC peering networks.

### `set_inputs` (Required)
A single string parsing interface used to inject configurations into your Helm chart template dynamically. Ensure there are no stray spaces around the separating colons (`:`).
* **Example Syntax:** `"serviceAccount.create:false,serviceAccount.name:default,configuration.provider:gcp"`

---

## Prerequisites: Creating and Pushing the OCI Chart Image

Before running the Terraform code to deploy a **private** Helm chart, the chart must be packaged and hosted in your Google Artifact Registry as an OCI image. Follow these 4 steps to prepare your registry and push your package:

### Step-1 (Create an Artifact Registry Repository)
Create a Docker/OCI-compatible repository inside your Google Cloud project via the gcloud CLI:
```bash
gcloud artifacts repositories create <ARTIFACT_REGISTRY_REPO_NAME> \
    --repository-format=docker \
    --location=<REGION> \
    --description="OCI Helm Charts Repository"
```
### Step-2 (Authenticate in Artifact Registry)
Create a Docker/OCI-compatible repository inside your Google Cloud project via the gcloud CLI:
```bash
gcloud auth print-access-token | helm registry login -u oauth2accesstoken --password-stdin <REGION>-docker.pkg.dev
```
### Step-3 (Create Helm Package)
Navigate to your local chart directory containing your Chart.yaml file and compress it into a standard .tgz archive target:
```bash
helm package .
```
### Step-4 (Push Helm OCI Image into Artifact Registry)
Upload your freshly generated chart archive tarball straight up to your private repository endpoint path:
```bash
helm push velero-*.tgz oci://<REGION>-docker.pkg.dev/<PROJECT_ID>/<ARTIFACT_REGISTRY_REPO_NAME>
```
