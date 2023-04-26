SHELL := /bin/bash

env-setup:
	rm -rf venv
	python3.8 -m venv venv; \
	source venv/bin/activate; \
	pip install -r requirements.txt



run-local:
	source venv/bin/activate; \
	export CONFIG_PATH=configs/local.cfg; \
	python manage.py makemigrations; \
	python manage.py migrate; \
	black .; \
	python manage.py runserver

run-dev:
	source venv/bin/activate; \
	pip install -r requirements.txt; \
	export CONFIG_PATH=configs/dev.cfg; \
	python manage.py makemigrations; \
	python manage.py migrate; \
	rm -rf sample_django_project/static; \
	python manage.py collectstatic; \
	sudo systemctl restart venv
