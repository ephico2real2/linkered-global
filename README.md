# Linkerd Namespace Annotator
---

### Introduction

This project provides a shell script for annotating Kubernetes namespaces for Linkerd service mesh injection.

Future State:
- Dockerize the shell scripts
- Kubernetes cronjob or job with kustomize to auto create the configmap from provided configuration file

## Prerequisites

Ensure the following tools are installed:

- `kubectl`
- `yq`

### Installing `yq`

For most systems:

```bash
sudo apt-get install yq
```

Or for MacOS using Homebrew:

```bash
brew install yq
```

## Usage

### CLI Options

| Option        | Description                                                   |
|---------------|---------------------------------------------------------------|
| `-f`          | Path to the YAML configuration file                           |
| `-n`          | Namespace(s) to annotate (can be specified multiple times)    |
| `-a`          | Annotation state for Linkerd injection (enabled or disabled)  |
| `--dry-run`   | Simulate the changes without applying them                    |
| `--verbose`   | Enable verbose output                                         |

### Examples

#### Using Configuration File

To annotate namespaces based on a configuration file:

```bash
./linkerd_namespace_annotator.sh -f /path/to/namespaces_config.yaml
```

#### Using CLI Arguments

To annotate specific namespaces with CLI arguments:

```bash
./linkerd_namespace_annotator.sh -n namespace1 -n namespace2 -a enabled
```

#### Dry Run with CLI Arguments

To perform a dry run (simulation) with CLI arguments:

```bash
./linkerd_namespace_annotator.sh -n namespace1 -n namespace2 -a enabled --dry-run
```

#### Verbose Output with CLI Arguments

To enable verbose logging with CLI arguments:

```bash
./linkerd_namespace_annotator.sh -n namespace1 -n namespace2 -a enabled --verbose
```

#### Dry Run and Verbose Output with CLI Arguments

To perform a dry run and enable verbose logging with CLI arguments:

```bash
./linkerd_namespace_annotator.sh -n namespace1 -n namespace2 -a enabled --dry-run --verbose
```

### Configuration File

You can specify verbose and dry run settings in the YAML configuration file. These settings will be used unless overridden by CLI options.

#### Sample `namespaces_config.yaml`

```yaml
verbose: true
dryRun: true
namespaces:
  - name: namespace1
    annotation: enabled
  - name: namespace2
    annotation: disabled
  - name: namespace3
    annotation: enabled
  - name: namespace4
    annotation: disabled
```

   ```bash
   cat <<EOF > namespaces_config.yaml
   verbose: true
   dryRun: true
   namespaces:
     - name: namespace1
       annotation: enabled
     - name: namespace2
       annotation: disabled
     - name: namespace3
       annotation: enabled
     - name: namespace4
       annotation: disabled
   EOF
  ```

#### Explanation:

- **verbose:** Enables verbose logging when set to `true`.
- **dryRun:** Simulates changes without applying them when set to `true`.
- **namespaces:** An array of namespaces to annotate.
  - **name:** The name of the namespace.
  - **annotation:** The annotation state for Linkerd injection (`enabled` or `disabled`).

### Overriding YAML Settings with CLI Options

CLI options can override the settings specified in the YAML configuration file.

#### Example: Dry Run (CLI Overrides YAML)

To perform a dry run, overriding the `dryRun` setting in the YAML file:

```bash
./linkerd_namespace_annotator.sh -f /path/to/namespaces_config.yaml --dry-run
```

#### Example: Verbose Output (CLI Overrides YAML)

To enable verbose logging, overriding the `verbose` setting in the YAML file:

```bash
./linkerd_namespace_annotator.sh -f /path/to/namespaces_config.yaml --verbose
```

## Building and Running Locally

1. **Run the Shell Script:**

   ```bash
   ./linkerd_namespace_annotator.sh -n namespace1 -n namespace2 -a enabled
   ```

2. **Run the Shell Script with Configuration File:**

   ```bash
   ./linkerd_namespace_annotator.sh -f /path/to/namespaces_config.yaml
   ```

### Additional Information

- **Environment Variable Handling:** The script uses the `KUBECONFIG` environment variable if available.
- **Validation:** Ensures required CLI tools (`kubectl`, `yq`) are installed.

---
