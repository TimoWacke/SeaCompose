SHELL := /bin/bash
.PHONY: build clone nginx-conf clean certbot

default: clean nginx-conf clone build certbot

clone:
# Clone the frontend and backend repositories
	source ../.env && \
	source ./.env && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_BACKEND.git ./backend && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_FRONTEND.git ./frontend && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_FINANCE.git ./finance
	

build: 
# Build the Docker Compose services
	docker-compose build
# Run the Docker Compose services
	docker-compose up -d

# For Domain in $FRONTEND_REDIRECT_DOMAINS, $BACKEND_DOMAINS, $FRONTEND_PRIMARY_DOMAIN
# run docker-compose certbot command with -d domain
certbot:
	source ../.env && \
	source ./.env && \
	for domain in $$FRONTEND_REDIRECT_DOMAINS $$BACKEND_DOMAINS $$FRONTEND_PRIMARY_DOMAIN $$FINANCE_DOMAINS; do \
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
	docker-compose restart loyalty-nginx


nginx-conf:
# for each domain in $FRONTEND_REDIRECT_DOMAINS, $BACKEND_DOMAINS, $FRONTEND_PRIMARY_DOMAIN
# with the corresponding template in ./nginx
# sed substitute the domain in the correct template and appends to ./nginx/default.conf
	rm -rf ./nginx/default.conf
	touch ./nginx/default.conf
	source ./../.env && \
	source ./.env && \
	for domain in $$FRONTEND_REDIRECT_DOMAINS; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/@DOMAIN/$$domain/g"  ./nginx/template.frontendredirect >> ./nginx/default.conf; \
	done && \
	for domain in $$BACKEND_DOMAINS; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/\@DOMAIN/$$domain/g"  ./nginx/template.backend >> ./nginx/default.conf; \
	done && \
	for domain in $$FRONTEND_PRIMARY_DOMAIN; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/\@DOMAIN/$$domain/g" ./nginx/template.frontend >> ./nginx/default.conf; \
	done && \
	for domain in $$FINANCE_DOMAINS; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/\@DOMAIN/$$domain/g" ./nginx/template.finance >> ./nginx/default.conf; \
	done

clean:
	docker-compose down
	rm -rf ./frontend
	rm -rf ./backend
	rm -rf ./finance
	rm -rf ./nginx/default.conf

