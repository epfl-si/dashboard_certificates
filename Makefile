setup:
	@mkdir -p elastic/data elastic/logs

vm-max_map_count:
	@if [ "$$(uname)" = "Linux" ]; then \
		sudo sysctl -w vm.max_map_count=262144 1>/dev/null && echo "vm.max_map_count changed"; \
	fi

up: setup vm-max_map_count
	@docker compose up -d

logs:
	docker compose logs -f 

exec-elastic:
	docker compose exec elasticsearch bash

exec-kibana:
	docker compose exec kibana bash

stop:
	docker compose stop

clean:
	sudo rm -rf ./elastic