FROM node:15-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5022
CMD ["node", "index.js"]
