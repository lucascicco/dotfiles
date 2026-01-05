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

# kubernetes/openshift
# context & namespace
alias kctx='kubectx'
alias kns='kubens'
alias kgctx='${KUBE_CMD} config get-contexts -o name'
alias kcuc='${KUBE_CMD} config use-context'
alias kcns='${KUBE_CMD} config set-context --current --namespace'

# common flags
export kdry='--dry-run=client -o yaml'
export know='--force --grace-period 0'

# get
alias kg='${KUBE_CMD} get'
alias kga='${KUBE_CMD} get all'
alias kgaa='${KUBE_CMD} get all -A'
alias kgp='${KUBE_CMD} get pods'
alias kgpa='${KUBE_CMD} get pods -A'
alias kgpw='${KUBE_CMD} get pods -w'
alias kgd='${KUBE_CMD} get deploy'
alias kgda='${KUBE_CMD} get deploy -A'
alias kgs='${KUBE_CMD} get svc'
alias kgsa='${KUBE_CMD} get svc -A'
alias kgi='${KUBE_CMD} get ingress'
alias kgia='${KUBE_CMD} get ingress -A'
alias kgcm='${KUBE_CMD} get configmap'
alias kgsec='${KUBE_CMD} get secret'
alias kgno='${KUBE_CMD} get nodes'
alias kgns='${KUBE_CMD} get namespaces'
alias kgpv='${KUBE_CMD} get pv'
alias kgpvc='${KUBE_CMD} get pvc'
alias kgev='${KUBE_CMD} get events --sort-by=.lastTimestamp'

# describe
alias kd='${KUBE_CMD} describe'
alias kdp='${KUBE_CMD} describe pod'
alias kdd='${KUBE_CMD} describe deploy'
alias kds='${KUBE_CMD} describe svc'
alias kdno='${KUBE_CMD} describe node'

# logs
alias klo='${KUBE_CMD} logs'
alias klof='${KUBE_CMD} logs -f'
alias klop='${KUBE_CMD} logs -p'

# exec
alias kex='${KUBE_CMD} exec -it'
alias kexsh='${KUBE_CMD} exec -it -- sh'
alias kexbash='${KUBE_CMD} exec -it -- bash'

# edit & apply
alias ke='${KUBE_CMD} edit'
alias ka='${KUBE_CMD} apply -f'
alias kak='${KUBE_CMD} apply -k'
alias kdel='${KUBE_CMD} delete'
alias kdelf='${KUBE_CMD} delete -f'

# scale & rollout
alias ksc='${KUBE_CMD} scale'
alias kro='${KUBE_CMD} rollout'
alias kros='${KUBE_CMD} rollout status'
alias kroh='${KUBE_CMD} rollout history'
alias krou='${KUBE_CMD} rollout undo'
alias kror='${KUBE_CMD} rollout restart'

# port-forward & proxy
alias kpf='${KUBE_CMD} port-forward'
alias kproxy='${KUBE_CMD} proxy'

# top (metrics)
alias ktop='${KUBE_CMD} top'
alias ktopp='${KUBE_CMD} top pods'
alias ktopn='${KUBE_CMD} top nodes'

# openshift specific (oc)
alias ocl='oc login'
alias ocw='oc whoami'
alias ocproj='oc project'
alias ocprojs='oc projects'
alias ocnew='oc new-project'

# git-sync aliases (loaded from YAML config)
GIT_SYNC_SCRIPT="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/utils/git-sync.sh"
[[ -s "$GIT_SYNC_SCRIPT" ]] && source "$GIT_SYNC_SCRIPT"
