Prerequisites:

- Xperience by Kentico license file (https://docs.kentico.com/developers-and-admins/installation/licenses)
- installed GIT
- .NET 8 or .NET 9 installed (https://dotnet.microsoft.com/en-us/download/dotnet/8.0) 
- installed docker switched into linux containers

Other information:
- you can change some settings before installation in docker/.env file
- by default you will install Dancing Goat Kentico demo, you can change it

Installation process:

1) copy your license.txt file into the root directory of the repository
2) open terminal/powershell and change location into 'docker' folder from this repository
3) run start.ps1 to 'warm up' containers, geneartes the certs and make sure that SQL Server container is running (answer yes to all questions and do not set any password for certificates)
4) run start.ps1 -Init (answer yes to all questions)
5) run stop.ps1 to stop the containers
6) run start.ps1 to reset all of the containers, after a minute or two you should be able to see your XbK instance via https://localhost
7) you can log in into your kentico via url https://localhost/admin with username 'administrator' and password 'password'

Available tools:
- Traefik dashboard: http://localhost:8080/
- SqlServer available through Sql Server Management Studio on localhost with login 'sa' and password 'yourStrong(!)Password'
