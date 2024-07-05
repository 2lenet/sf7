EXEC := $(shell if [ -f /.dockerenv ]; then \
    	echo ""; \
	else \
    	echo "docker-compose exec symfony"; \
	fi)
CONSOLE = $(EXEC) bin/console
PROJECT := $(shell basename ${CURDIR})

# Run once after composer create-project
init:
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' docker-compose.yaml
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' Dockerfile
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' Makefile
	sed -i -E 's/\[PROJECT\]/${PROJECT}/g' sonar-project.properties
	sed -i -E 's/\[PROJECT\]/${PROJECT}/g' .env
	sed -i -E 's/\[PROJECT\]/${PROJECT}/g' .gitlab-ci.yml
	sed -i -E 's/2lenet\/project/2lenet\/${PROJECT}/g' composer.json
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' dbtest/build.sh
	sed -i -E 's/\[PROJECT\]/$(PROJECT)/g' dbtest/Dockerfile
	echo "build dbtest"
	cd dbtest; ./build.sh

# Install project
install:
	docker-compose build
	docker-compose run symfony composer install
	docker-compose run symfony npm install
	docker-compose run symfony chmod -R 777 var

# Start project
start:
	docker-compose up -d
	@echo "Sf at http://127.0.0.1:8000/"
	@echo "PMA at http://127.0.0.1:9000/"

# Stop project
stop:
	docker-compose down --remove-orphans

build:
	docker build --build-arg app_version=dev-${CI_PIPELINE_ID} -t registry.2le.net/2le/[PROJECT] .
	docker push registry.2le.net/2le/[PROJECT]

# Clear cache
cc:
	$(CONSOLE) cache:clear

# Get into Symfony docker bash
console:
	docker-compose exec symfony bash

# Run migrations
prepare:
	bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration
	bin/console translation:pull loco --force
	bin/console cache:clear -q
	bin/console credential:load
	bin/console assets:install --symlink
	#chmod -R 777 data

# Download translations from Loco
translate:
	$(CONSOLE) translation:pull loco --force

# Start watching asset files
wp-watch:
	$(EXEC) ./node_modules/.bin/encore dev --watch

# Run tests
test:
	#$(CONSOLE) lint:container
	#$(CONSOLE) lint:twig templates
	$(EXEC) ./vendor/bin/phpcs
	$(EXEC) ./vendor/bin/phpstan analyse
	$(EXEC) cp phpunit.xml.dist phpunit.xml
	$(CONSOLE) doctrine:database:create --if-not-exists --env=test
	$(CONSOLE) doctrine:migrations:migrate --no-interaction --allow-no-migration --env=test
	#$(CONSOLE doctrine:fixtures:load -n --env=test
	$(EXEC) bin/phpunit tests/ -v --coverage-clover phpunit-coverage.xml --log-junit phpunit-report.xml