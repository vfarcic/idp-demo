#!/bin/sh

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--margin "1 2" --padding "2 4" \
	'Destroy all the resources created for the TODO: video.'

gum confirm '
Are you ready to start?
Feel free to say "No" and inspect the script if you prefer destroying resources manually.
' || exit 0

################
# Requirements #
################

echo "You will need following tools installed:"
echo "
|Name            |Required     |More info                                            |
|----------------|-------------|-----------------------------------------------------|
|Charm Gum       |Yes          |\"https://github.com/charmbracelet/gum#installation\"|
|gitHub CLi      |Yes          |\"https://youtu.be/BII6ZY2Rnlc\"                     |
|Google Cloud CLI|If using Google Cloud|\"https://cloud.google.com/sdk/docs/install\"|
" \
    | gum format
gum confirm "
Do you have those tools installed?
" || exit 0

###########
# Destroy #
###########

source .env

gh repo view $GITHUB_ORG/idp-demo-app --web

echo '
Open "Settings" followed by "Delete this repository" and follow the instructions to remove the forked repository.'

gum input --placeholder "
Press the enter key to continue."

gh repo view $GITHUB_ORG/idp-demo --web

echo '
Open "Settings" followed by "Delete this repository" and follow the instructions to remove the forked repository.'

gum input --placeholder "
Press the enter key to continue."

echo '
Delete all entities and blueprints from Port.'

gum input --placeholder "
Press the enter key to continue."

if [[ "$HYPERSCALER" == "google" ]]; then

    gcloud projects delete $PROJECT_ID

    rm -f account.json gcp-creds.json gke_gcloud_auth_plugin_cache

elif [[ "$HYPERSCALER" == "aws" ]]; then

    eksctl delete cluster --config-file idp-demo/eksctl-config.yaml

    rm -f aws-creds.conf

fi

rm -rf idp-demo idp-demo-app kubeconfig.yaml
