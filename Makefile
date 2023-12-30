SHELL := /bin/bash
.PHONY: build clone nginx-conf clean certbot nginx

default: nginx-conf clone build

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
	docker-compose down
# Make the loyalty and rvssn services
	make -C ./rvssn
	make -C ./josefine
	make -C ./decrypto
#	make -C ./loyalty

# merge loyalty/nginx/default.conf and rvssn/nginx/default.conf
# into nginx/default.conf
	rm -rf ./nginx/default.conf
	touch ./nginx/default.conf
	cat ./loyalty/nginx/default.conf >> ./nginx/default.conf
	cat ./rvssn/nginx/default.conf >> ./nginx/default.conf

# Build the Docker Compose services
	docker-compose build
# Run the Docker Compose services
	docker-compose up -d

	chmod -R 755 ./certbot/conf
	docker-compose restart nginx

nginx:
# merge loyalty/nginx/default.conf and rvssn/nginx/default.conf
# into nginx/default.conf
	rm -rf ./nginx/default.conf
	touch ./nginx/default.conf
	cat ./loyalty/nginx/default.conf >> ./nginx/default.conf
	cat ./rvssn/nginx/default.conf >> ./nginx/default.conf
	cat ./josefine/nginx/default.conf >> ./nginx/default.conf
	cat ./decrypto/nginx/default.conf >> ./nginx/default.conf

	docker-compose restart nginx

clean:
	rm -rf ./loyalty/.env
	rm -rf ./loyalty/finance.env
	rm -rf ./rvssn/.env
	rm -rf .env
