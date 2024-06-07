reformat_ssl_json:
	chmod +x ./prod_to_dev/reformat_json.bash
	./prod_to_dev/reformat_json.bash
	rm ./prod_to_dev/ssl.json
	rm ./prod_to_dev/temp_ssl.json
	mv ./prod_to_dev/formated_ssl.json ./prod_to_dev/ssl.json

setup:
	@mkdir -p volumes/elastic/data volumes/elastic/logs volumes/shiny volumes/sqlite
	
vm-max_map_count:
	@if [ "$$(uname)" = "Linux" ]; then \
		sudo sysctl -w vm.max_map_count=262144 1>/dev/null && echo "vm.max_map_count changed"; \
	fi

export_data: .containers_availables
	@echo "Mapping of cmdb index" && curl -X PUT "http://localhost:9200/cmdb" -H "Content-Type: application/json" -d @./prod_to_dev/mapping_cmdb.json
	@echo "Pull elasticdump image" && docker pull elasticdump/elasticsearch-dump
	@echo "Load cmdb index in elasticsearch" && docker run --net=host --rm -ti -v ./prod_to_dev/internal_data:/tmp elasticdump/elasticsearch-dump \
	--input=/tmp/cmdb.json \
	--output=http://localhost:9200/cmdb \
	--type=data
	@echo "Load ssl index in elasticsearch" && docker run --net=host --rm -ti -v ./prod_to_dev/internal_data:/tmp elasticdump/elasticsearch-dump \
	--input=/tmp/ssl.json \
	--output=http://localhost:9200/ssl \
	--type=data

init: setup vm-max_map_count
	docker compose up --build -d
	touch .containers_availables
	$(MAKE) export_data
	curl -XPUT "http://localhost:9200/_settings" -H "Content-Type: application/json" -d '{"index.max_result_window": 1000000}'
	cp ./start_files/cmdb_empty.sqlite ./volumes/sqlite/cmdb.sqlite
	docker exec -it ss RScript /home/sqlite/add_cmdb_data.R
	cp ./start_files/wip_start_dashboard.R ./volumes/shiny/dashboard.R
	docker exec -it ss RScript /home/shiny/dashboard.R
	touch .data_loaded

.data_loaded:
	$(MAKE) init

up: .data_loaded vm-max_map_count
	@docker compose up -d
	$(MAKE) logs

logs:
	docker compose logs -f 

exec-elastic:
	docker compose exec elasticsearch bash

exec-kibana:
	docker compose exec kibana bash

exec-shiny:
	docker compose exec shiny bash

stop:
	docker compose stop

clean:
	docker compose stop
	docker system prune
	rm -rf ./volumes
	rm .data_loaded
	rm .containers_availables