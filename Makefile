SHELL := /bin/bash
.PHONY: build clone nginx-conf clean

default: clean nginx-conf clone build certbot

build: 
# Build the Docker Compose services
	docker-compose build
# Run the Docker Compose services
	docker-compose up -d

# For Domain in $FRONTEND_REDIRECT_DOMAINS, $BACKEND_DOMAINS, $FRONTEND_PRIMARY_DOMAIN
# run docker-compose certbot command with -d domain
certbot:
	source .env && \
	source ./loyalty/.env && \
	for domain in $$FRONTEND_REDIRECT_DOMAINS $$BACKEND_DOMAINS $$FRONTEND_PRIMARY_DOMAIN; do \
		docker-compose run --rm --entrypoint "\
			certbot certonly --webroot -w /var/www/certbot \
			--email $$GIT_EMAIL \
			--agree-tos \
			--keep-until-expiring \
			--rsa-key-size 4096 \
			-d $$domain \
			" certbot; \
	done
# Change Permissions
	chmod -R 755 ./data/certbot/conf
# Restart Nginx
	docker-compose restart nginx

# Permissions
	chmod -R 755 ./data/certbot/conf
	docker-compose restart nginx
clone:
	source .env && \
	git config --global user.email "$$GIT_EMAIL" && \
	git config --global user.name "$$GIT_USER" && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_FRONTEND.git ./loyalty/frontend && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_BACKEND.git ./loyalty/backend
	
nginx-conf:
	apt install dos2unix
	dos2unix ./loyalty/.env
	source ./loyalty/.env && \
	envsubst \
		'$$FRONTEND_PRIMARY_DOMAIN, $$FRONTEND_REDIRECT_DOMAINS, $$BACKEND_DOMAINS, $$PORT'  \
	 < loyalty/nginx.template.conf > loyalty/nginx/default.conf

clean:
	docker-compose down
	rm -rf ./loyalty/frontend
	rm -rf ./loyalty/backend
	rm -rf ./loyalty/nginx/default.conf
