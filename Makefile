.PHONY: build
build:
	docker rm -f dev-env > error.log
	docker rmi -f dev-env > error.log
	docker build -t dev-env --build-arg GH_TOKEN=${GH_TOKEN} .

build-start:
	make build
	make run

.PHONY: build-no-cache
build-no-cache:
	docker build --no-cache -t dev-env .

.PHONY: run
run:
	# docker run -v ~/code:/root/code -p 8000:8000 --name dev-env -it dev-env
	docker run -v ~/code:/home/developer/code -p 8000:8000 --name dev-env -it dev-env
.PHONY: re-run
re-run:
	docker rm -f dev-env > error.log
	make run

.PHONY: start
start:
	docker start dev-env
	docker attach dev-env

.PHONY: rebuild-n-start
rebuild-n-start:
	make build
	make run
