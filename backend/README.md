# Backend

This is backend for "versus.kg" application

# Installation instructions

## Ubuntu and Ubuntu-based

### Python

1. Install prerequisites for Python build:

```bash

sudo apt-get update

sudo apt-get install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

```

1. Install pyenv: https://github.com/pyenv/pyenv#basic-github-checkout

1. Install Python: `pyenv install 3.7.4`

1. Install pyenv-virtualenv: https://github.com/pyenv/pyenv-virtualenv

1. Create virtualenv while in project directory: `pyenv virtualenv 3.7.4 vs-api-venv`

* Virtualenv name `vs-api-venv` is important because `.python-version` also points to it.

It is needed for virtualenv to be activated automatically when you enter project directory and deactivated when you leave.

# Running dev server

Install prerequisites if using MySQL:

```
sudo apt-get install python3-dev default-libmysqlclient-dev
```

In activated virtualenv install requirements:

```
pip install -r requirements.txt
```

### In order to use the application, we need to create a new database in MySQL. Follow these steps:

1. Open your MySQL command-line tool

2. Run the following command to create a new database:

```angular2html

> CREATE DATABASE DATABASE_NAME CHARACTER SET utf8

```

Replace *DATABASE_NAME* with the name you want for your database.

3. Set Database Credentials as Environment Variables:

To connect the application to the database, we need to provide the database credentials as environment variables. These are the variables you'll need to set:

- MYSQL_ROOT_PASSWORD: The password for the MySQL root user. This is usually set during MySQL installation.

- MYSQL_DATABASE: The name of the database you created in Step 1 (e.g., *DATABASE_NAME*).

- MYSQL_USER: The username for accessing the database. You can choose a username.

- MYSQL_PASSWORD: The password for the database user. Choose a secure password.

- MYSQL_HOST: The hostname or IP address where the MySQL database is hosted. If it's hosted locally, you can use localhost.

- MYSQL_PORT: The port on which MySQL is running. The default is usually 3306.

Make sure to set these environment variables with the appropriate values before running the application. These credentials allow the application to establish a connection to the MySQL database you created.

Then run migrations:

```
./manage.py migrate
```

Seed fixtures:

```
./manage.py loaddata data.json
```

This will create a super user with username `admin` and password `Password123`

Run the backend dev server:

```
./manage.py runserver
```

# Running tests

```
./manage.py test
```