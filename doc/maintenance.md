# Maintenance script

The script `maintenance.sh` can be used to regularly update the Server, services stack and finally to reboot the host if it is needed.

The  script can be executed manually or to be scheduled for automated execution with cron:

```
# crontab -e
```
Add the following line:
```
0 4 * * 6 /home/ubuntu/home-server/scripts/maintenance.sh 2>&1 | /home/ubuntu/home-server/scripts/timestamp.sh >> /home/ubuntu/logs/maintenance.log
```

The script will be executed [At 04:00 on Saturday](https://crontab.guru/#0_4_*_*_6). Logs from result are stored in file `/home/ubuntu/logs/maintenance.log`.

Or other proposition is `0 4 15-22 * */2` - At 04:00 on Tuesday - in the middle of month between 15th and 22nd.

To cleanup old log file content configure the logrotate by creating the file `/etc/logrotate.d/server.maintenance` with content:
```
/home/ubuntu/logs/maintenance.log {
        monthly
        copytruncate
        missingok
        rotate 12
        compress
        delaycompress
        notifempty
}
```
# Upgrade Postgre versions
Major versions of PostgreSQL require data storage to be upgraded, or data to be exported/imported in new DB storage file. 
Here are the sequence of commands how to export/import all data from each one of the databases that are present. 

## Upgrade keycloakdb
```
docker compose --env-file .env.server up -d keycloakdb
docker compose --env-file .env.server exec keycloakdb pg_dumpall -U postgre > dumpk.sql
docker compose --env-file .env.server down
// Manually delete old data folder
// Manually increase version in docker-compose
docker compose --env-file .env.server up -d keycloakdb
cat dumpk.sql | docker exec -i keycloakdb psql -U postgre
docker compose --env-file .env.server down
docker compose --env-file .env.server up -d
```

## Upgrade mealiedb
```
docker compose --env-file .env.server up -d meailedb
docker compose --env-file .env.server exec meailedb pg_dumpall -p 5632 -U meailedb > dumpm.sql
docker compose --env-file .env.server down
// Manually delete old data folder
// Manually increase version in docker-compose
docker compose --env-file .env.server up -d meailedb
cat dumpm.sql | docker exec -i meailedb psql -p 5632 -U meailedb
docker compose --env-file .env.server down
docker compose --env-file .env.server up -d
```

## Upgrade domodb
```
docker compose --env-file .env.server up -d domodb
docker compose --env-file .env.server exec domodb pg_dumpall -p 5532 -U domodb > dumpd.sql
docker compose --env-file .env.server down
// Manually delete old data folder
// Manually increase version in docker-compose
docker compose --env-file .env.server up -d domodb
cat dumpd.sql | docker exec -i domodb psql -p 5532 -U domodb
docker compose --env-file .env.server down
docker compose --env-file .env.server up -d
```
