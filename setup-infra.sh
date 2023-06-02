#!/bin/sh
set -e

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--margin "1 2" --padding "2 4" \
	'Setup for the 
"TODO:"
video.'

gum confirm '
Are you ready to start?
Feel free to say "No" and inspect the script if you prefer setting up resources manually.
' || exit 0

################
# Requirements #
################

echo "
## You will need following tools installed:
|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|Charm Gum       |Yes                  |'https://github.com/charmbracelet/gum#installation'|
|kubectl         |Yes                  |'https://kubernetes.io/docs/tasks/tools/#kubectl'  |
|helm            |Yes                  |'https://helm.sh/docs/intro/install/'              |
|jq              |Yes                  |'https://stedolan.github.io/jq/download'           |
|yq              |Yes                  |'https://github.com/mikefarah/yq#install'          |
" | gum format

gum confirm "
Do you have those tools installed?
" || exit 0

##############
# Crossplane #
##############

kubectl apply --filename crossplane-config/config-kubernetes.yaml

kubectl apply --filename crossplane-config/provider-civo.yaml

kubectl wait --for=condition=healthy provider.pkg.crossplane.io --all --timeout=300s

CIVO_TOKEN=$(gum input --placeholder "Please enter Civo (https://civo.com) token." --password --value "$CIVO_TOKEN")

CIVO_TOKEN_ENCODED=$(echo $CIVO_TOKEN | base64)

echo "apiVersion: v1
kind: Secret
metadata:
  name: civo-creds
type: Opaque
data:
  credentials: $CIVO_TOKEN_ENCODED" \
    | kubectl --namespace crossplane-system apply --filename -

kubectl apply --filename crossplane-config/provider-config-civo.yaml

###########
# Argo CD #
###########

kubectl create namespace infra

# Install `yq` from https://github.com/mikefarah/yq if you do not have it already
yq --inplace ".server.ingress.hosts[0] = \"argocd.$INGRESS_HOST.nip.io\"" argocd/helm-values.yaml

helm upgrade --install argocd argo-cd --repo https://argoproj.github.io/argo-helm --namespace argocd --create-namespace --values argocd/helm-values.yaml --wait

kubectl apply --filename argocd/project.yaml

yq --inplace ".spec.source.repoURL = \"https://github.com/$GITHUB_ORG/idp-demo\"" argocd/apps.yaml

yq --inplace ".spec.source.repoURL = \"https://github.com/${GITHUB_ORG}/idp-demo.git\"" argocd/cluster-template.yaml

kubectl apply --filename argocd/apps.yaml

########
# Port #
########

cat port/cluster-create-action.json \
    | jq ".invocationMethod.org = \"$GITHUB_ORG\"" \
    | tee port/cluster-create-action.json.tmp

mv port/cluster-create-action.json.tmp port/cluster-create-action.json

cat port/cluster-delete-action.json \
    | jq ".invocationMethod.org = \"$GITHUB_ORG\"" \
    | tee port/cluster-delete-action.json.tmp

mv port/cluster-delete-action.json.tmp port/cluster-delete-action.json

########
# Repo #
########

git add .

git commit -m "Infrastructure setup"

git push
