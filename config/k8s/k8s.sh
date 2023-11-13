#!/bin/bash

CMD=$(command -v kubecolor >/dev/null 2>&1 && echo "kubecolor" || echo "kubectl")

# kubectl alias
alias k='${CMD}'
alias kctx='kubectl-ctx'
alias kns='kubectl-ns'
alias kgctx='${CMD} config get-contexts -o name'
alias kct='kubectl config use-context '
alias kn='kubectl config set-context --current --namespace '

# exports
export do='--dry-run=client -o yaml'
export now='--force --grace-period 0'

alias kpo='${CMD} get po'
alias klo='${CMD} logs'
alias kpoa='${CMD} get po -A'
alias kpow='${CMD} get po -w'
alias knod='${CMD} get nodes'
