SHELL := /bin/bash
.PHONY: build clone clean certbot

default: clean clone build certbot

clone:
# Clone the repository
	source ../.env && \
	git clone https://github.com/TimoWacke/DecryptoGame.git ./repository

	chmod -R 755 ./repository
# give the user www-data access to the frontend directory
	chown -R www-data:www-data ./repository

build: 
# Build the Docker Compose services
	docker-compose build
# Run the Docker Compose services
	docker-compose up -d

# For Domain in $FRONTEND_REDIRECT_DOMAINS, $BACKEND_DOMAINS, $FRONTEND_PRIMARY_DOMAIN
# run docker-compose certbot command with -d domain
certbot:
	source ../.env && \
	for domain in decrypto.sea.hamburg; do \
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
	cd .. && docker-compose stop nginx && cd ./decrypto
	docker-compose down
	rm -rf ./repository


