#!/usr/bin/env bash
set -e
SERVICE_NAME=$1
RELEASE_VERSION=$2

sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

mkdir -p golang/"${SERVICE_NAME}"

protoc --go_out ./golang --go_opt paths=source_relative \
--go-grpc_out ./golang --go-grpc_opt paths=source_relative \
./"${SERVICE_NAME}"/*.proto

cd golang/"${SERVICE_NAME}"
go mod init github.com/MuhamedUsman/ecommerce-microservice-proto/golang/"${SERVICE_NAME}" || true
go mod tidy
cd ../..

git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_USERNAME}"
(git add . && git commit -am "proto update") || true
git push -u origin HEAD
git tag -d "${RELEASE_VERSION}" || true
git push --delete origin "${RELEASE_VERSION}" || true
git tag -fa golang/"${SERVICE_NAME}"/"${RELEASE_VERSION}" \
-m "golang/${SERVICE_NAME}/${RELEASE_VERSION}"
git push origin refs/tags/golang/"${SERVICE_NAME}"/"${RELEASE_VERSION}"