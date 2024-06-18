#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -f <config_file> | -n <namespace> -a <annotation> [--dry-run] [--verbose]"
  echo "  -f <config_file>       Path to the YAML configuration file"
  echo "  -n <namespace>         Namespace(s) to annotate (can be specified multiple times)"
  echo "  -a <annotation>        Annotation state for Linkerd injection (enabled|disabled)"
  echo "  --dry-run              Simulate the changes without applying them"
  echo "  --verbose              Enable verbose output"
  exit 1
}

# Function to log messages
log() {
  if [ "$VERBOSE" = true ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
  fi
}

# Function to validate CLI tools are installed
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

# Function to check if a namespace has the desired annotation
check_annotation() {
  local namespace=$1
  local annotation=$2
  current_annotation=$(kubectl get namespace "$namespace" -o jsonpath='{.metadata.annotations.linkerd\.io/inject}' 2>/dev/null)
  [ "$current_annotation" == "$annotation" ]
}

# Function to annotate a namespace
annotate_namespace() {
  local namespace=$1
  local annotation=$2

  if check_annotation "$namespace" "$annotation"; then
    log "Namespace $namespace already annotated with linkerd.io/inject=$annotation. Skipping."
    return
  fi

  log "Annotating namespace: $namespace with linkerd.io/inject=$annotation"
  if [ "$DRY_RUN" = true ]; then
    log "Dry run: Would annotate namespace $namespace with linkerd.io/inject=$annotation"
    kubectl annotate namespace "$namespace" linkerd.io/inject="$annotation" --overwrite --dry-run=client
  else
    kubectl annotate namespace "$namespace" linkerd.io/inject="$annotation" --overwrite
    if [ $? -eq 0 ]; then
      log "Successfully annotated namespace $namespace."
    else
      log "Failed to annotate namespace $namespace."
    fi
  fi
}

# Function to process a YAML configuration file
process_config_file() {
  local config_file=$1

  # Read verbose and dryRun settings from YAML if not overridden by CLI
  if [ -z "$VERBOSE_CLI" ]; then
    VERBOSE=$(yq eval '.verbose' "$config_file")
  fi
  if [ -z "$DRY_RUN_CLI" ]; then
    DRY_RUN=$(yq eval '.dryRun' "$config_file")
  fi

  namespace_count=$(yq eval '.namespaces | length' "$config_file")
  for (( i=0; i<namespace_count; i++ )); do
    name=$(yq eval ".namespaces[$i].name" "$config_file")
    annotation=$(yq eval ".namespaces[$i].annotation" "$config_file")
    if [ "$annotation" != "enabled" ] && [ "$annotation" != "disabled" ]; then
      log "Invalid annotation value for namespace $name. Must be 'enabled' or 'disabled'. Skipping."
      continue
    fi
    annotate_namespace "$name" "$annotation"
  done
}

# Parse command-line arguments
NAMESPACES=()
ANNOTATION=""
CONFIG_FILE=""
DRY_RUN_CLI=""
VERBOSE_CLI=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -f) CONFIG_FILE="$2"; shift ;;
    -n) NAMESPACES+=("$2"); shift ;;
    -a) ANNOTATION="$2"; shift ;;
    --dry-run) DRY_RUN_CLI=true ;;
    --verbose) VERBOSE_CLI=true ;;
    *) echo "Unknown parameter passed: $1"; usage ;;
  esac
  shift
done

# Override YAML settings with CLI flags if provided
[ -n "$VERBOSE_CLI" ] && VERBOSE=true
[ -n "$DRY_RUN_CLI" ] && DRY_RUN=true

# Validate required tools are installed
validate_tools

# Validate and process input
if [ "${#NAMESPACES[@]}" -gt 0 ] && [ -n "$ANNOTATION" ]; then
  for namespace in "${NAMESPACES[@]}"; do
    annotate_namespace "$namespace" "$ANNOTATION"
  done
elif [ -n "$CONFIG_FILE" ]; then
  process_config_file "$CONFIG_FILE"
else
  usage
fi
