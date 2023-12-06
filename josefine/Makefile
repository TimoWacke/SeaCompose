SHELL := /bin/bash
.PHONY: build clone clean certbot

default: clean clone build certbot

clone:
# Clone the frontend and backend repositories
	source ../.env && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/josefinehenkel.git ./frontend

	chmod -R 755 ./frontend
# give the user www-data access to the frontend directory
	chown -R www-data:www-data ./frontend

build: 
# Build the Docker Compose services
	docker-compose build
# Run the Docker Compose services
	docker-compose up -d

# For Domain in $FRONTEND_REDIRECT_DOMAINS, $BACKEND_DOMAINS, $FRONTEND_PRIMARY_DOMAIN
# run docker-compose certbot command with -d domain
certbot:
	source ../.env && \
	for domain in josefine-henkel.sea.hamburg; do \
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
	chmod -R 755 ../certbot/conf

# Restart Nginx
	make nginx -C ..


clean:
	docker-compose down
	rm -rf ./frontend


