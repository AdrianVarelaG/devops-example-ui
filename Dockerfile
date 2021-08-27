FROM node:10.19.0-alpine as base
WORKDIR /app
COPY ["package.json", "package-lock.json", "./"]
RUN npm install
COPY . .

FROM base as test
RUN CI=true npm test

FROM base as lint
RUN npm run lint

FROM base as builder
RUN npm run build

FROM nginx:1.18-alpine as release
EXPOSE 80
STOPSIGNAL SIGQUIT
COPY conf /etc/nginx
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/build .

CMD ["nginx", "-g", "daemon off;"]