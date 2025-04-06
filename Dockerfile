FROM node:lts-alpine

WORKDIR /app

COPY . .

RUN npm install

CMD ["sh", "-c", "node index.js $TOKEN"]

