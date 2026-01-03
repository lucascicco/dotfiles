# zsh aliases
alias c="clear"

function kube-toggle() {
  if [[ -n "$STARSHIP_K8S" ]]; then
    unset STARSHIP_K8S
  else
    export STARSHIP_K8S=1
  fi
}

# terraform
alias tf="tofu "
alias tg="terragrunt"

# workspace
alias wk="jump wk"
alias lf="jump lf"

# git
alias lg="lazygit"

# kubernetes (kubectl)
alias kctx='kubectx'
alias kns='kubens'
alias kgctx='${KUBE_CMD} config get-contexts -o name'
alias kct='kubectl config use-context '
alias kn='kubectl config set-context --current --namespace '

export kdry='--dry-run=client -o yaml'
export know='--force --grace-period 0'

alias kpo='${KUBE_CMD} get po'
alias klo='${KUBE_CMD} logs'
alias kpoa='${KUBE_CMD} get po -A'
alias kpow='${KUBE_CMD} get po -w'
alias knod='${KUBE_CMD} get nodes'
