#!/bin/sh

docker-compose build simple-repo-neo4j-test-s || exit

docker-compose up -d --build simple-repo-neo4j-db-test-s

docker-compose run simple-repo-neo4j-test-s

#docker-compose down
