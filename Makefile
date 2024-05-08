setup:
	@mkdir -p elastic/data elastic/logs shiny
	
vm-max_map_count:
	@if [ "$$(uname)" = "Linux" ]; then \
		sudo sysctl -w vm.max_map_count=262144 1>/dev/null && echo "vm.max_map_count changed"; \
	fi

up: environment data

environment: setup vm-max_map_count
	@docker compose up

data:
	@echo "Mapping of cmdb index" && curl -X PUT "http://localhost:9200/cmdb" -H "Content-Type: application/json" -d @./data/mapping_cmdb.json
	@echo "Pull elasticdump image" && docker pull elasticdump/elasticsearch-dump
	@echo "Load ssl index in elasticsearch" && docker run --net=host --rm -ti -v ./elasticdump:/tmp elasticdump/elasticsearch-dump \
	--input=/tmp/ssl.json \
	--output=http://localhost:9200/ssl \
	--type=data
	@echo "Load cmdb index in elasticsearch" && docker run --net=host --rm -ti -v ./elasticdump:/tmp elasticdump/elasticsearch-dump \
	--input=/tmp/cmdb.json \
	--output=http://localhost:9200/cmdb \
	--type=data

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
	sudo rm -rf ./elastic