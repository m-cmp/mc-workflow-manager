FROM docker.io/nginx:1.17.6-alpine

COPY dist /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]