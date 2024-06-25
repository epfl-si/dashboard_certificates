sed 's/$/,/' ./prod_to_dev/ssl.json > ./prod_to_dev/temp_ssl.json
sed -i '$ s/.$//' ./prod_to_dev/temp_ssl.json
#echo '{"data":[' | cat - ./prod_to_dev/temp_ssl.json > ./prod_to_dev/formated_ssl.json
#echo "]}" >> ./prod_to_dev/formated_ssl.json