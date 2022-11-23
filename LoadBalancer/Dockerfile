FROM node:latest

WORKDIR /nodejs/app

COPY package*.json ./ 

RUN npm install

COPY . .

CMD ["node", "index.js"]