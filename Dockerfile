FROM node:latest

WORKDIR /docs

COPY . .

RUN npm install -g docsify-cli@latest

EXPOSE 3000
  
ENTRYPOINT docsify serve .