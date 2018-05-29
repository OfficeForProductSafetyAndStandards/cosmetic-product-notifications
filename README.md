# BEIS - Market Surveillance & Product Safety Digital Service

## Getting Setup
Install Docker
Install docker-compose

```
docker-compose build
docker-compose up
```
Then in a different terminal initialise the DB
```
docker-compose run web rake db:create
```
Visit the site on localhost:3000

### Windows Subsystem for Linux
`sudo ln -s /mnt/c /c`
`cd /c/path/to/project`
(from https://medium.com/software-development-stories/developing-a-dockerized-web-app-on-windows-subsystem-for-linux-wsl-61efec965080)

## First time setup
https://docs.docker.com/compose/rails
