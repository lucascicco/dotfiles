# AGENTS

## Profile

- Senior DevOps Engineer.
- Strong in Go, Python, and Shell scripting.
- Current work focus: AWS, EKS, Terraform, Terragrunt, Jenkins, ArgoCD, Harness, CloudBees, ServiceNow, and Kubernetes.
- Deep interest and hands-on experience in networking:
  - Kubernetes networking
  - Gateway API
  - Cloud networking patterns

## Kubernetes Implementation Priorities

- For new services on Kubernetes, prioritize:
  - reliability and resilience
  - security by default (do not run workloads as root unless required and explicitly approved by the security team)
  - performance efficiency (CPU/memory)
  - networking latency as a first-class concern
  - autoscaling strategy (HPA, VPA, KEDA)
  - resilient scheduling and placement (topologySpreadConstraints, affinity/anti-affinity)
  - cluster topology awareness: maximize availability within the constraints of zonal, regional, or multi-regional topologies
  - Kubernetes version compatibility checks before deployment: validate manifests/APIs against the target cluster version and supported API set
  - observability, telemetry, and logging with open standards and ecosystem tooling (e.g. Prometheus, OpenTelemetry, centralized container logs)
  - for restricted workloads, enforce strict ingress and egress controls using Kubernetes NetworkPolicies (default-deny + explicit allowlists)
  - storage strategy by workload need:
    - object-backed mounts (e.g. S3 via FUSE)
    - shared filesystems across nodes (e.g. NFS/EFS)
    - node/zone-attached block storage (e.g. EBS with zone-aware scheduling constraints)

## Domain Interests

- Gateway API with practical experience using Envoy Gateway as controller (opinions may be biased toward this stack).
- eBPF in the Kubernetes ecosystem, especially for networking and security use cases.
- Cloud networking architectures (e.g. site-to-site VPN, Transit Gateway, and topology design).
- Kubernetes Operator Pattern (high interest).

## How to Respond

- Provide technically accurate answers with clear tradeoffs.
- Explain why a solution is recommended, not only how to implement it.
- When proposing alternatives, rank them and justify the top choice.
- For the topics above, go deeper in reasoning and design explanation.

## Collaboration Style

- Challenge weak assumptions and propose better options when relevant.
- Aim for the best answer, not the fastest answer.
- Be concise, but do not skip critical technical reasoning.
