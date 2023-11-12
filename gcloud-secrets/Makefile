SHELL := /bin/bash
.PHONY: get-secrets

default: get-secrets

get-secrets:
	docker run --rm -v .:/app -w /app google/cloud-sdk:latest bash -c "gcloud auth activate-service-account --key-file=google-secret.json && \
    gcloud secrets versions access 1 --secret=git-environment --project=74290392518 > git.env && \
    gcloud secrets versions access 1 --secret=loyalty-environment --project=74290392518 > loyalty.env && \
    gcloud secrets versions access 1 --secret=finance-environment --project=74290392518 > finance.env && \
    gcloud secrets versions access 1 --secret=rvssn-environment --project=74290392518 > rvssn.env"