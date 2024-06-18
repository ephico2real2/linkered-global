# linkered-global
---
### Updated `linkerd_namespace_annotator.sh`

```bash
#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -f <config_file> | -n <namespace1> -n <namespace2> ... -a <enabled|disabled> [--dry-run] [--verbose]"
  echo "  -f <config_file>       Path to the YAML configuration file"
  echo "  -n <namespace>         Namespace(s) to annotate"
  echo "  -a <enabled|disabled>  Annotation state for Linkerd injection (required with -n)"
  echo "  --dry-run              Simulate the changes without applying them"
  echo "  --verbose              Enable verbose output"
  exit 1
}

# Function to log messages
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to validate yq and kubectl CLI are installed
validate_tools() {
  if ! command -v kubectl &> /dev/null; then
    log "kubectl CLI is not installed. Please install it and try again."
    exit 1
  fi
  if ! command -v yq &> /dev/null; then
    log "yq is not installed. Please install it and try again."
    exit 1
  fi
}

# Function to validate kubectl context
validate_kubectl_context() {
  if ! kubectl cluster-info > /dev/null 2>&1; then
    log "kubectl context is not set correctly. Please configure it and try again."
    exit 1
  fi
}

# Function to check if namespace already has the desired annotation
check_annotation() {
  local namespace=$1
  local annotation=$2

  current_annotation=$(kubectl get namespace "${namespace}" -o jsonpath='{.metadata.annotations.linkerd\.io/inject}' 2>/dev/null)
  if [ "${current_annotation}" == "${annotation}" ]; then
    return 0  # Annotation matches
  else
    return 1  # Annotation does not match or is not present
  fi
}

# Function to annotate a namespace
annotate_namespace() {
  local namespace=$1
  local annotation=$2
  local dry_run_flag=""

  if [ "$DRY_RUN" = true ]; then
    dry_run_flag="--dry-run=client"
    log "Dry run: Would annotate namespace ${namespace} with linkerd.io/inject=${annotation}"
  else
    log "Annotating namespace: ${namespace} with linkerd.io/inject=${annotation}"
  fi

  if check_annotation "${namespace}" "${annotation}"; then
    log "Namespace ${namespace} already annotated with linkerd.io/inject=${annotation}. Skipping."
    return
  fi

  if kubectl annotate namespace "${namespace}" "linkerd.io/inject=${annotation}" --overwrite ${dry_run_flag}; then
    log "Successfully annotated namespace ${namespace}."
  else
    log "Failed to annotate namespace ${namespace}. Continuing to next."
  fi
}

# Validate yq and kubectl CLI
validate_tools

# Validate kubectl context
validate_kubectl_context

# Parse command-line arguments
NAMESPACES=()
DRY_RUN=false
VERBOSE=false
while getopts "f:n:a:h" opt; do
  case ${opt} in
    f)
      CONFIG_FILE=${OPTARG}
      ;;
    n)
      NAMESPACES+=("${OPTARG}")
      ;;
    a)
      CLI_ANNOTATION=${OPTARG}
      ;;
    h)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

# Process additional long options
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      set -x
      shift
      ;;
  esac
done

# If CLI arguments are provided, use them
if [ ${#NAMESPACES[@]} -gt 0 ]; then
  if [ -z "${CLI_ANNOTATION}" ]; then
    log "Annotation state must be specified with -a when using -n."
    usage
  fi
  if [[ "${CLI_ANNOTATION}" != "enabled" && "${CLI_ANNOTATION}" != "disabled" ]]; then
    log "Invalid annotation value. Must be 'enabled' or 'disabled'."
    usage
  fi
  for namespace in "${NAMESPACES[@]}"; do
    annotate_namespace "${namespace}" "${CLI_ANNOTATION}"
  done
  exit 0
fi

# Validate the configuration file exists and is readable
if [ -n "${CONFIG_FILE}" ] && [ -r "${CONFIG_FILE}" ]; then
  # Read the YAML configuration file and loop over each namespace configuration
  namespace_count=$(yq eval '.namespaces | length' "${CONFIG_FILE}")
  for (( i=0; i<namespace_count; i++ )); do
    NAMESPACE=$(yq eval ".namespaces[$i].name" "${CONFIG_FILE}")
    ANNOTATION=$(yq eval ".namespaces[$i].annotation" "${CONFIG_FILE}")

    if [[ "${ANNOTATION}" != "enabled" && "${ANNOTATION}" != "disabled" ]]; then
      log "Invalid annotation value for namespace ${NAMESPACE}. Must be 'enabled' or 'disabled'. Skipping this entry."
      continue
    fi

    annotate_namespace "${NAMESPACE}" "${ANNOTATION}"
  done
else
  log "Configuration file not provided or not readable, and no CLI arguments provided."
  usage
fi
```

### Usage Examples

1. **Using CLI Arguments with Multiple Namespaces:**

   ```bash
   ./linkerd_namespace_annotator.sh -n my-namespace1 -n my-namespace2 -a enabled
   ```

   ```bash
   ./linkerd_namespace_annotator.sh -n my-namespace3 -n my-namespace4 -a disabled
   ```

2. **Using a Configuration File:**

   ```bash
   ./linkerd_namespace_annotator.sh -f namespaces_config.yaml
   ```

3. **Dry Run:**

   ```bash
   ./linkerd_namespace_annotator.sh -n my-namespace1 -n my-namespace2 -a enabled --dry-run
   ```

4. **Verbose Output:**

   ```bash
   ./linkerd_namespace_annotator.sh -n my-namespace1 -n my-namespace2 -a enabled --verbose
   ```
   
```bash
This updated script now uses the `--dry-run=client` flag with `kubectl` to simulate the changes without applying them.
It also checks if the namespace already has the desired annotation before attempting to apply it.
```
---
