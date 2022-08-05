#!/bin/bash

CMD=$(command -v kubecolor >/dev/null 2>&1 || echo "kubectl" && echo "kubecolor")

# kubectl pods
alias k='${CMD}'
alias kg='${CMD} get'
alias kgpod='${CMD} get pod'
alias kgall=${CMD} get --all-namespaces all
alias kdp='${CMD} describe pod'
# kubectl apply
alias kap='${CMD} apply'
# kubectl delete
alias krm='${CMD} delete'
alias krmf='${CMD} delete -f'
# kubectl services
alias kgsvc='${CMD} get service'
# kubectl deployments
alias kgdep='${CMD} get deployments'
# kubectl misc
alias kl='${CMD} logs'
alias klf='${CMD} logs -f'
alias kei='kubectl exec -it'
# context
alias kctx='kubectl-ctx'
# namespace
alias kns='kubectl-ns'
