### JIRA Story

**Title:** Automate Namespace Annotations for Linkerd Service Mesh

**Description:**

Create a script to automate the annotation of namespaces for the Linkerd service mesh. The script should support both command-line options and reading from a YAML configuration file. It should also include features for dry runs and verbose output. The goal is to streamline the process of annotating namespaces, ensuring consistency and reducing manual effort.

**Acceptance Criteria:**

1. **Script Development:**
   - Create a bash script (`linkerd_namespace_annotator.sh`) to annotate namespaces for Linkerd injection.
   - Support specifying multiple namespaces via command-line arguments.
   - Support reading namespace annotations from a YAML configuration file.
   - Ensure the script checks for existing annotations and only updates if necessary.

2. **Script Features:**
   - Include a dry run option (`--dry-run`) to simulate changes without applying them.
   - Include a verbose option (`--verbose`) to enable detailed output for debugging purposes.
   - Validate the presence of required CLI tools (`kubectl` and `yq`) before execution.
   - Implement error handling to log issues and continue processing remaining namespaces.

3. **Testing:**
   - Test the script with various scenarios to ensure it works as expected.
   - Verify correct annotation of namespaces.
   - Ensure the dry run and verbose modes function correctly.

4. **Documentation:**
   - Provide clear usage examples for both command-line and YAML configurations.
   - Document the script functionalities and options for ease of use.

**Tasks:**

1. Develop the initial version of `linkerd_namespace_annotator.sh`.
2. Implement support for multiple namespaces via CLI.
3. Implement support for reading from a YAML configuration file.
4. Add functionality to check for existing annotations.
5. Add dry run and verbose options.
6. Validate the presence of required CLI tools.
7. Implement error handling and logging.
8. Test the script in various scenarios.
9. Document usage examples and script functionalities.
10. Review and refine the script based on feedback.


**Labels:** Linkerd, Automation, Kubernetes, Scripting

