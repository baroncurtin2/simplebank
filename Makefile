DB_URL=postgresql://root:secret@localhost:5433/simple_bank?sslmode=disable

postgres:
	docker run --name postgres -p 5433:5432 --network bank-network -e POSTGRES_PASSWORD=secret -e POSTGRES_USER=root -d postgres:15.1-alpine

start-postgres:
	docker start postgres

stop-postgres:
	docker stop postgres

createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres dropdb simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/baroncurtin2/simplebank/db/sqlc Store

db_docs:
	dbdocs build docs/db.dbml

db_schema:
	dbml2sql --postgres -o docs/schema.sql docs/db.dbml

proto:
	rm -f pb/*.go
	rm -f docs/swagger/*.swagger.json
	protoc --proto_path=proto \
		--go_out=pb \
		--go_opt=paths=source_relative \
        --go-grpc_out=pb \
        --go-grpc_opt=paths=source_relative \
        --grpc-gateway_out=pb \
        --grpc-gateway_opt=paths=source_relative \
        --openapiv2_out=docs/swagger \
        --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
        proto/*.proto

evans:
	evans --host localhost --port 9090 -r repl

.PHONY: postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 start-postgres stop-postgres test server \
 	mock db_docs db_schema proto evans