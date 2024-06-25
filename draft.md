### Status Update - [Date]

#### Linkerd Work

Yesterday was extensive and productive on Linkerd:

1. **Linkerd Namespace Annotator Scripts:**
   - Collaborated with Ron to test Linkerd namespace annotator scripts on two namespaces: `fleet-legal` and `fleet-email` in the `UPD2 dev-us-5g-urp2-1` cluster.
   - After applying namespace annotations using `kubectl`, observed that a rollout of all deployments in the namespaces is necessary for Linkerd to inject the sidecar proxy.
   - We have now meshed all namespaces and the Kafka namespace.

2. **Cluster Shared Services:**
   - Worked on meshing primary and deadletter Kafka in the `dev-us` environment. 
   - Tested communications using Redpanda for deadletter:
     - Confirmed topic creation and existence in the browser.
     - Verified successful Telnet connection with trusty netshoot pod.
   - Stripped out Vault configuration from deadletter Kafka and set the protocol to PLAINTEXT, followed by a Helm upgrade.
   - Laid out files similar to the Kafka upgrade for easier application of changes.

3. **Troubleshooting and Findings:**
   - After removing Vault, expected Redpanda to not connect after unmeshing, but found it was still connecting.
   - Discovered that the default setting in the Linkerd Helm chart is `all-unauthenticated`, meaning any pod could communicate with Redpanda.
   - Tested by adding the `all-authenticated` setting using `kubectl`, which then prevented Redpanda and netshoot from connecting as expected.
   - Found that using the `config.linkerd.io/default-inbound-policy` annotation can control this behavior.

4. **Discovery of Linkerd Annotations:**
   - Discovered the `config.linkerd.io/default-inbound-policy` annotation to set the inbound policy to `all-authenticated`.
   - Considered exploring this annotation for other services and removing Vault configurations from other setups.
   - Used the `config.linkerd.io/skip-outbound-ports` annotation on Kafka and Zookeeper to skip internally used ports for communication between broker and Zookeeper cluster.

**Next Steps:**
- Further investigate and finalize the settings required for Linkerd to handle authenticated and unauthenticated traffic appropriately.
- Explore additional Linkerd annotations and configurations to optimize the service mesh integration and security.

**Blockers:**
- None at the moment.

**Acknowledgements:**
- Special thanks to Ron for his valuable insights and documentation, which have been instrumental in our discussions on automation and troubleshooting.

### Relevant Linkerd Annotations

1. **Setting Inbound Policy:**

   ```bash
   kubectl annotate namespace your-namespace config.linkerd.io/default-inbound-policy=all-authenticated
   ```

2. **Opting Out of Linkerd Injection:**

   ```yaml
   metadata:
     annotations:
       linkerd.io/inject: disabled
   ```

3. **Skipping Ports for Kafka and Zookeeper:**

   ```yaml
   metadata:
     annotations:
       config.linkerd.io/skip-outbound-ports: "2181,2888,3888"
   ```

### Documentation References

- [Linkerd Annotations](https://linkerd.io/2.11/reference/proxy-configuration/#proxy-configuration-through-annotations)
- [Configuring Inbound Policies](https://linkerd.io/2.11/reference/inbound-policy/#default-inbound-policy)
- [Skipping Ports](https://linkerd.io/2.11/reference/proxy-configuration/#configlinkerdioskip-outbound-ports)

By leveraging these annotations and configurations, we can further optimize our Linkerd deployment, improve security, and enhance operational efficiency.
