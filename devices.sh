#!/bin/bash

TOKENS_FILE="device_tokens.txt"
COMPOSE_FILE="devices.yml"
CONTAINER_NAME_PREFIX="virtual_device"

generate_compose_file() {
  echo "services:" > "$COMPOSE_FILE"

  i=1
  while IFS= read -r TOKEN || [[ -n "$TOKEN" ]]; do
    if [[ -z "$TOKEN" ]]; then continue; fi

    echo "  ${CONTAINER_NAME_PREFIX}_$i:" >> "$COMPOSE_FILE"
    echo "    build:" >> "$COMPOSE_FILE"
    echo "      context: ./" >> "$COMPOSE_FILE"
    echo "    environment:" >> "$COMPOSE_FILE"
    echo "      - TOKEN=$TOKEN" >> "$COMPOSE_FILE"
    echo "    restart: always" >> "$COMPOSE_FILE"
    echo "    networks:" >> "$COMPOSE_FILE"
    echo "      - compose_ws-network" >> "$COMPOSE_FILE"
    echo "" >> "$COMPOSE_FILE"

    ((i++))
  done < "$TOKENS_FILE"

    echo "networks:" >> "$COMPOSE_FILE"
    echo "  compose_ws-network:" >> "$COMPOSE_FILE"
    echo "      external: true" >> "$COMPOSE_FILE"
    echo "" >> "$COMPOSE_FILE"
}

FILES=("$COMPOSE_FILE")
COMPOSE_ARGS=""
for FILE in "${FILES[@]}"; do
  COMPOSE_ARGS="$COMPOSE_ARGS -f $FILE"
done

case $1 in
  up)
    generate_compose_file
    docker-compose $COMPOSE_ARGS up -d
    ;;
  down)
    docker-compose $COMPOSE_ARGS down
    ;;
  build)
    generate_compose_file
    docker-compose $COMPOSE_ARGS build
    ;;
  logs)
    docker-compose $COMPOSE_ARGS logs -f --tail=100
    ;;
  restart)
    docker-compose $COMPOSE_ARGS restart $2
    ;;
  *)
    echo "Usage: $0 {up|down|build|logs|restart <service>}"
    ;;
esac
