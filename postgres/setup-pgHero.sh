#!/usr/bin/env bash
echo "
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 10000
track_activity_query_size = 2048" >> /var/lib/postgresql/data/postgresql.conf
