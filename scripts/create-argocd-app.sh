NAME=$1
REPO_ORG=$2
REPO_NAME=$3
ENVIRONMENT=$4

FILE_PATH=apps/${NAME}-${ENVIRONMENT}.yaml

cp argocd/app-template.yaml $FILE_PATH
yq --inplace ".metadata.name = \"${NAME}\"" $FILE_PATH
yq --inplace ".spec.source.repoURL = \"https://github.com/${REPO_ORG}/${REPO_NAME}.git\"" $FILE_PATH
yq --inplace ".spec.source.path = \"kustomize/overlays/${ENVIRONMENT}\"" $FILE_PATH
yq --inplace ".spec.destination.namespace = \"${ENVIRONMENT}\"" $FILE_PATH
