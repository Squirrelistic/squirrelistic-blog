## Intro

This docker image is based on the code from https://github.com/microsoft/mssql-docker repository and is for **Windows** MSSQL container.

If you want to run MSSQL in a Linux container, use an [official Microsoft docker image](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16).

## Build an MSSQL Server in Windows Container image locally

Note that the Docker will download ~1.5GB SQL Server Developer Edition installer ISO Image.  If you plan to build docker images more than once, I recommend setting up a local file server to host the installers.

Choose which SQL Server (Developer Edition) version you need (2019 or 2022) and which base Windows Server image should be used (ltsc2019 or ltsc2022)

You won't be able to build ltsc2022 image on Windows 10 (only on Windows 11 or on Windows 2022 Server).

Build MSSQL Server 2022 with Windows 2019 Server base.

```
docker build -t mssqlserver:2022-ltsc2019 --build-arg SQL_VERSION=2022 --build-arg WIN_VERSION=ltsc2019 .
```

Build MSSQL Server 2022 with Windows 2022 Server base.

```
docker build -t mssqlserver:2022-ltsc2022 --build-arg SQL_VERSION=2022 --build-arg WIN_VERSION=ltsc2022 .
```

Build MSSQL Server 2019 with Windows 2019 Server base.

```
docker build -t mssqlserver:2019-ltsc2019 --build-arg SQL_VERSION=2019 --build-arg WIN_VERSION=ltsc2019 .
```

Build MSSQL Server 2019 with Windows 2022 Server base.

```
docker build -t mssqlserver:2019-ltsc2022 --build-arg SQL_VERSION=2019 --build-arg WIN_VERSION=ltsc2022 .
```

#### Build an MSSQL Server in Windows Container image using GitHub action

Fork the [squirrelistic-blog](https://github.com/Squirrelistic/squirrelistic-blog) repo.

Go to forked repository settings => secrets => actions and create 3 secrets, pointing to your **private** Docker repository.

- REGISTRY_LOGIN_SERVER
- REGISTRY_PASSWORD
- REGISTRY_USERNAME

Go to actions, select 'Build and Push MSSQL Server Windows Docker Image' and click 'Run Workflow'.

Select the desired version of MSSQL and Windows Server base, and it should be cooked and ready to eat in about 20 minutes.

#### How do I run this thing?

Run the MSSQL Server with a specific password (the default password is PleaseChangeMe!) and use your own custom MSSQL TCP port (8443).

Make sure the password adheres to the MSSQL Server [password policy](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16).

```
docker run --rm -it -p 8433:1433 -e sa_password=DictionaryNinja! mssqlserver:2022-ltsc2019
```

You can now log in to MSSQL using SQL Management Studio.

If you want to attach a database at the start of the container, you can use attach_dbs environment variable.

```
docker run --rm -it -p 8433:1433 -v c:/Temp/DataDirOnHost:c:/SqlData -e attach_dbs="[{'dbName':'Hello','dbFiles':['C:\\SqlData\\hello.mdf','C:\\SqlData\\hello_log.ldf']}]" mssqlserver:2022-ltsc2019
```
