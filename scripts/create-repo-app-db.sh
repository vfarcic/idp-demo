export GITHUB_TOKEN=$1
export GITHUB_USER=$2
export APP=$3
export IMAGE_REPO=$4
export HOST=$5
export DB_VERSION=$6
export DB_SIZE=$7

env

curl -fsSL https://download.devstream.io/download.sh | bash
chmod +x dtm
curl -H "Cache-Control: no-cache, no-store" -o config.yaml https://raw.githubusercontent.com/vfarcic/template-go-backend-db-google/main/config.yaml
ls -la
./dtm init --config-file config.yaml
./dtm apply --config-file config.yaml --yes
rm dtm config.yaml devstream.state
