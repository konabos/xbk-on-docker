<h1>Xperience by Kentico on Docker</h1>

With scripts provided in this repository you can easily install the newest XbK version in isolated environment.
You can use these containers to:

- learn about Xperience by Kentico
- learn about the latest releases
- build a base for your local development

<h2>Prerequisite</h2>

- Xperience by Kentico license file (https://docs.kentico.com/developers-and-admins/installation/licenses)
- (Windows only)enabled virtualization
- installed GIT
- .NET 8 or .NET 9 installed (https://dotnet.microsoft.com/en-us/download/dotnet/8.0) 
- installed Docker Desktop for macOS/Windows
- (Windows only) switched into linux containers
- (Windows only) changed execution policy ``Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass``
- (Windows only) stop other services running on your environment (IIS, SQL Server)


<h2>Other information</h2>

- you can change some settings before installation in ``docker/.env`` file
- by default you will install ``Dancing Goat Kentico`` demo, you can change it
- scripts will generate certificates that you can re-use in multiple directories by copy&paste into `docker\certs` directory

<h2>Installation process and usage</h2>

1) copy your ``license.txt`` file into the root directory of the repository
2) open terminal/powershell and change location into ``'docker'`` folder from this repository
3) run ``start.ps1 -Init`` (answer yes to all questions, and __DO NOT SET ANY PASSWORD__ for certificates)
4) at the end of installation, if everything went fine, script will open your ``https://localhost`` in a default browser
5) you can log in into your kentico via url ``https://localhost/admin`` with username __'administrator'__ and password __'password'__
6) when you stop your work, run `stop.ps1` script to stop containers and prune the data.

<h2>Available tools</h2>

- Traefik dashboard: ``http://localhost:8080/``
- SqlServer available through Sql Server Management Studio on localhost with login __'sa'__ and password __'yourStrong(!)Password'__ (if you have not changed it in your `.env` file)

<h2>Troubleshooting</h2>

- if you see 502 error in your browser, then it means that something is wrong with traefik, try to stop and start containers again
- if you see 404 error in your browser, it means that your Kestrel serwer is still not running, wait a minute so it can load
- you can always review logs of the docker containers with help of Visual Studio Code or Docker Desktop