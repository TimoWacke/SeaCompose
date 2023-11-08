SHELL := /bin/bash
.PHONY: build clone nginx-conf clean certbot

default: clean envinit move-envs nginx-conf clone build certbot

envinit:
	make -C ./gcloud-secrets

move-envs:
	mv gcloud-secrets/git.env .env
	mv gcloud-secrets/loyalty.env ./loyalty/.env


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
	chmod -R 755 ./certbot/conf
	chmod -R 755 ./loyalty/frontend/dist
# Restart Nginx
	docker-compose restart nginx

	chmod -R 755 ./certbot/conf
	docker-compose restart nginx
clone:
	source .env && \
	git config --global user.email "$$GIT_EMAIL" && \
	git config --global user.name "$$GIT_USER" && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_FRONTEND.git ./loyalty/frontend && \
	git clone https://$$GIT_TOKEN@github.com/$$GIT_USER/$$GIT_REPO_BACKEND.git ./loyalty/backend
	
nginx-conf:
# for each domain in $FRONTEND_REDIRECT_DOMAINS, $BACKEND_DOMAINS, $FRONTEND_PRIMARY_DOMAIN
# with the corresponding template in ./nginx
# sed substitute the domain in the correct template and appends to ./nginx/default.conf
	rm -rf ./loyalty/nginx/default.conf
	touch ./loyalty/nginx/default.conf
	source .env	&& \
	source ./loyalty/.env && \
	for domain in $$FRONTEND_REDIRECT_DOMAINS; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/@DOMAIN/$$domain/g"  ./loyalty/nginx/template.frontendredirect >> ./loyalty/nginx/default.conf; \
	done && \
	for domain in $$BACKEND_DOMAINS; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/\@DOMAIN/$$domain/g"  ./loyalty/nginx/template.backend >> ./loyalty/nginx/default.conf; \
	done && \
	for domain in $$FRONTEND_PRIMARY_DOMAIN; do \
		echo Adding $$domain to nginx configuration && \
		sed "s/\@DOMAIN/$$domain/g" ./loyalty/nginx/template.frontend >> ./loyalty/nginx/default.conf; \
	done

clean:
	rm -rf ./loyalty/frontend
	rm -rf ./loyalty/backend
	rm -rf ./loyalty/nginx/default.conf
	rm -rf ./loyalty/.env
	rm -rf .env
