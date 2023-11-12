SHELL := /bin/bash
.PHONY: build clone nginx-conf clean certbot

default: clean envinit nginx-conf clone build

envinit:
	make -C ./gcloud-secrets
	mv gcloud-secrets/git.env .env
	mv gcloud-secrets/loyalty.env ./loyalty/.env
	mv gcloud-secrets/finance.env ./loyalty/finance.env
	mv gcloud-secrets/rvssn.env ./rvssn/.env
	source .env && \
	git config --global user.email "$$GIT_EMAIL" && \
	git config --global user.name "$$GIT_USER"


build: 
# Make the loyalty and rvssn services
	make -C ./loyalty
	make -C ./rvssn

# Build the Docker Compose services
	docker-compose build
# Run the Docker Compose services
	docker-compose up -d

	chmod -R 755 ./certbot/conf
	docker-compose restart nginx


clean:
	rm -rf ./loyalty/.env
	rm -rf ./loyalty/finance.env
	rm -rf ./rvssn/.env
	rm -rf .env
