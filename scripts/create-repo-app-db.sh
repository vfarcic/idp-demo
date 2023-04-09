export GITHUB_TOKEN=$1
export GITHUB_ORG=$2
export GITHUB_USER=$3
export APP=$4
export IMAGE_REPO=$5
export HOST=$6
export DB_VERSION=$7
export DB_SIZE=$8

curl -fsSL https://download.devstream.io/download.sh | bash
chmod +x dtm
curl -H "Cache-Control: no-cache, no-store" -o config.yaml https://raw.githubusercontent.com/vfarcic/template-go-backend-db-google/main/config.yaml
./dtm init --config-file config.yaml
./dtm apply --config-file config.yaml --yes
rm dtm config.yaml devstream.state
