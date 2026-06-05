FROM node:20-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev

COPY app.js ./

EXPOSE 2280

CMD ["node", "app.js"]
