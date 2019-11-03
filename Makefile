bundle:
	docker-compose exec web bundle

db-create:
	docker-compose exec web bash -l -c "bundle exec rails db:create"

db-migrate:
	docker-compose exec web bash -l -c "bundle exec rails db:migrate"

db-rollback:
	docker-compose exec web bash -l -c "bundle exec rails db:rollback"

test:
	docker-compose exec web bash -l -c "bundle exec rake"

yarn:
	docker-compose exec web bash -l -c "yarn install"

eslint:
	docker-compose exec web bash -l -c "yarn run eslint"

attach:
	docker attach time_clock_web_1

ssh:
	docker exec -it time_clock_web_1 bash
