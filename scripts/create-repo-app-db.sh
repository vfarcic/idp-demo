GITHUB_TOKEN=$1
GITHUB_USER=$2
APP=$3
IMAGE_REPO=$4
HOST=$5
DB_VERSION=$6
DB_SIZE=$7

curl -fsSL https://download.devstream.io/download.sh | bash
ls -la
chmod +x dtm
curl -o config.yaml https://raw.githubusercontent.com/vfarcic/template-go-backend-db-google/main/config.yaml
./dtm init --config-file config.yaml
./dtm apply --config-file config.yaml --yes
rm config.yaml devstream.state
