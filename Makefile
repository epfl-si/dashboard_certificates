up:
	sudo sysctl -w vm.max_map_count=262144
	mkdir -p elastic/data elastic/logs
	docker-compose up