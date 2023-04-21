FROM node:8.4.0

WORKDIR /app/

COPY . /app/

CMD ["node", "index.js"]

EXPOSE 8080