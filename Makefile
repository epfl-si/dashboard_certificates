GREEN = \033[0;32m
RED  = \033[0;31m
END = \033[0m
BORDER = "==========================="
DC = docker compose

setup:
	@mkdir -p elastic/data elastic/logs shiny
	@echo "${BORDER}"
	
vm-max_map_count:
	@if [ "$$(uname)" = "Linux" ]; then \
		sudo sysctl -w vm.max_map_count=262144 1>/dev/null && echo "vm.max_map_count changed"; \
	fi
	@echo "${BORDER}"

up: environment data

environment: setup vm-max_map_count
	@$(DC) up
	@echo "${BORDER}"

data:
	@echo "${GREEN}Mapping of cmdb index" && curl -X PUT "http://localhost:9200/cmdb" -H "Content-Type: application/json" -d @./data/mapping_cmdb.json
	@echo "${RED}Pull elasticdump image" && docker pull elasticdump/elasticsearch-dump
	@echo "Load ssl index in elasticsearch" && docker run --net=host --rm -ti -v ./elasticdump:/tmp elasticdump/elasticsearch-dump \
	--input=/tmp/ssl.json \
	--output=http://localhost:9200/ssl \
	--type=data
	@echo "Load cmdb index in elasticsearch" && docker run --net=host --rm -ti -v ./elasticdump:/tmp elasticdump/elasticsearch-dump \
	--input=/tmp/cmdb.json \
	--output=http://localhost:9200/cmdb \
	--type=data
	@echo "${BORDER}"

logs:
	docker compose logs -f
	@echo "${BORDER}"

exec-elastic:
	docker compose exec elasticsearch bash
	@echo "${BORDER}"

exec-kibana:
	docker compose exec kibana bash
	@echo "${BORDER}"

exec-shiny:
	docker compose exec shiny bash
	@echo "${BORDER}"

stop:
	docker compose stop
	@echo "${BORDER}"

clean:
	sudo rm -rf ./elastic
	@echo "${BORDER}"

test:
	@echo "${GREEN}Mapping of cmdb index${END}" && curl -X PUT "http://localhost:9200/cmdb" -H "Content-Type: application/json" -d @./data/mapping_cmdb.json
	@echo "${RED}Pull elasticdump image" && docker pull elasticdump/elasticsearch-dump
	@echo "${BORDER}"

motd:
	@echo ".------..------..------..------..------..------..------..------..------."
	@echo "|D.--. ||A.--. ||S.--. ||H.--. ||B.--. ||O.--. ||A.--. ||R.--. ||D.--. |"
	@echo "| :/\: || (\/) || :/\: || :/\: || :(): || :/\: || (\/) || :(): || :/\: |"
	@echo "| (__) || :\/: || :\/: || (__) || ()() || :\/: || :\/: || ()() || (__) |"
	@echo "| '--'D|| '--'A|| '--'S|| '--'H|| '--'B|| '--'O|| '--'A|| '--'R|| '--'D|"
	@echo "`------'`------'`------'`------'`------'`------'`------'`------'`------'"