# kubectl alias
alias k='${KUBE_CMD}'
alias kctx='kubectl-ctx'
alias kns='kubectl-ns'
alias kgctx='${KUBE_CMD} config get-contexts -o name'
alias kct='kubectl config use-context '
alias kn='kubectl config set-context --current --namespace '

# exports
export do='--dry-run=client -o yaml'
export now='--force --grace-period 0'

alias kpo='${KUBE_CMD} get po'
alias klo='${KUBE_CMD} logs'
alias kpoa='${KUBE_CMD} get po -A'
alias kpow='${KUBE_CMD} get po -w'
alias knod='${KUBE_CMD} get nodes'
