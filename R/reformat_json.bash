sed 's/$/,/' ./R/ssl.json > ./R/formated_ssl.json
sed -i '$ s/.$//' ./R/formated_ssl.json
echo '{"data":[' | cat - ./R/formated_ssl.json > ./R/clean_ssl.json
echo "]}" >> ./R/clean_ssl.json