#!/bin/sh

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--margin "1 2" --padding "2 4" \
	'Destroy all the resources created for the
"How To Create A Complete Internal Developer Platform (IDP)?"
video.'

gum confirm '
Are you ready to start?
Feel free to say "No" and inspect the script if you prefer destroying resources manually.
' || exit 0

################
# Requirements #
################

echo "You will need following tools installed:"
echo "
|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|Charm Gum       |Yes                  |'https://github.com/charmbracelet/gum#installation'|
|gitHub CLi      |Yes                  |'https://youtu.be/BII6ZY2Rnlc'                     |
|Google Cloud CLI|If using Google Cloud|'https://cloud.google.com/sdk/docs/install'        |
|AWS CLI         |If using AWS         |'https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html'|
|eksctl          |If using AWS         |'https://eksctl.io/introduction/#installation'     |
" | gum format

gum confirm "
Do you have those tools installed?
" || exit 0

###########
# Destroy #
###########

source .env

cd idp-demo

git pull

rm -rf infra/*.yaml apps/*.yaml

git add .

git commit -m "Destroy"

git push

if [[ "$HYPERSCALER" == "google" ]]; then

    gcloud projects delete $PROJECT_ID

    rm -f account.json gcp-creds.json gke_gcloud_auth_plugin_cache

elif [[ "$HYPERSCALER" == "aws" ]]; then

    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --margin "1 2" --padding "2 4" \
        "We need to wait until all the resources in $HYPERSCALER are destroyed." \
        "
    It might take a while..."

    COUNTER=$(kubectl get managed | grep -v object | grep -v PROVIDERCONFIG | wc -l)

    while [ $COUNTER -ne 0 ]; do
        sleep 10
        COUNTER=$(kubectl get managed | grep -v object | grep -v PROVIDERCONFIG | wc -l)
    done

    eksctl delete addon --name aws-ebs-csi-driver --cluster dot

    eksctl delete cluster --config-file eksctl-config.yaml

    rm -f aws-creds.conf

fi

gh repo view $GITHUB_ORG/idp-demo-app --web

echo "
Open \"Settings\" followed by \"Delete this repository\" and follow the instructions to remove the forked repository."

gum input --placeholder "
Press the enter key to continue."

gh repo view $GITHUB_ORG/idp-demo --web

echo "
Open \"Settings\" followed by \"Delete this repository\" and follow the instructions to remove the forked repository."

gum input --placeholder "
Press the enter key to continue."

echo "
Delete all entities and blueprints from Port."

gum input --placeholder "
Press the enter key to continue."

rm -rf idp-demo idp-demo-app kubeconfig.yaml .env
