NAME=$1
REPO_USER=$2
REPO_NAME=$3
ENVIRONMENT=$4

# sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
# sudo chmod a+x /usr/local/bin/yq

FILE_PATH=apps/${NAME}-${ENVIRONMENT}.yaml

cp argocd/app-template.yaml $FILE_PATH
yq --inplace ".metadata.name = \"${NAME}\"" $FILE_PATH
yq --inplace ".spec.source.repoURL = \"https://github.com/${REPO_USER}/${REPO_NAME}.git\"" $FILE_PATH
yq --inplace ".spec.source.path = \"kustomize/overlays/${ENVIRONMENT}\"" $FILE_PATH
yq --inplace ".spec.destination.namespace = \"${ENVIRONMENT}\"" $FILE_PATH

# TODO: Remove
cat apps/${NAME}-${ENVIRONMENT}.yaml