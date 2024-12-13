#!/bin/bash
echo "Configure database user"
read -p "Postgres user name: " name
read -s -p "Postgres user password: "; echo password 

export POSTGRES_USER=$name
export POSTGRES_PASSWORD=$password
export DB_NAME="twitter"

echo "Creating database container..."
sudo docker run -d \
  --name postgres_tweet \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$DB_NAME \
  -p 5432:5432 \
  --restart always \
  postgres:9.6.8-alpine

sleep 20 # Ensure enough time for postgres database to initialize

echo "Create table in database..."
docker exec -i postgres_tweet psql -U $POSTGRES_USER -d $DB_NAME <<-EOF
    create table last (
    id INT,
    name VARCHAR(50),
    followers INT,
    hashtag VARCHAR(50),
    lang VARCHAR(10),
    created TIMESTAMP);
EOF

#id
nl filename.txt > file_tweet.txt

echo "Inserting values into table..."
#insert_values
while read id name followers hashtag lang created;do
    docker exec -i postgres_tweet psql -U $POSTGRES_USER -d $DB_NAME <<-EOF
    insert into last (id, name, followers, hashtag, lang, created) values ('$id', '$name', '$followers', '$hashtag', '$lang', '$created');
EOF
done < file_tweet.txt

echo "Done!"
rm -f file_tweet.txt 
