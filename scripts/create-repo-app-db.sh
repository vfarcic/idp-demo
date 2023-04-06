GITHUB_TOKEN=$1
GITHUB_USER=$2
APP=$3
IMAGE_REPO=$4
HOST=$5
DB_VERSION=$6
DB_SIZE=$7

echo "xxx"
echo GITHUB_TOKEN $GITHUB_TOKEN
echo GITHUB_USER $GITHUB_USER
echo APP $APP
echo IMAGE_REPO $IMAGE_REPO
echo HOST $HOST
echo DB_VERSION $DB_VERSION
echo DB_SIZE $DB_SIZE
echo "xxx"

curl -fsSL https://download.devstream.io/download.sh | bash
chmod +x dtm
curl -o config.yaml https://raw.githubusercontent.com/vfarcic/template-go-backend-db-google/main/config.yaml
ls -la
./dtm init --config-file config.yaml
./dtm apply --config-file config.yaml --yes
rm config.yaml devstream.state
