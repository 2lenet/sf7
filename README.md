# sf7
Sf7 2le project template

To bootstrap a project use the following steps:

```bash
composer create-project 2lenet/sf7 project_name --no-scripts
```

or with docker :
```bash
docker run -it -v $PWD:/var/www/html registry.2le.net/2le/2le:base-sf6 composer create-project 2lenet/sf7 project_name --no-scripts
```

Say Yes to all recipes question exept Doctrine


```
cd project_name
make init
make install
```
add the project to git ( git init or add to existing project )

```
make start
```

Create your first migration for bundle entities

```
make console
bin/console make:migration
bin/console doc:mi:mi
```


This will create your project, modify all reference to [PROJECT] in config files

After that you have :

* sf7 project
* Docker and Docker Compose config
* CI with test, build and deploy
* PHPStan, PHPCS and SonarQube configuration
