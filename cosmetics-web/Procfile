web: cp -r /workspace/db-copy/* /workspace/db/ && bin/rails server
jobs: bin/sidekiq -C config/sidekiq.yml
js: yarn build --watch
css: yarn build:css --watch
