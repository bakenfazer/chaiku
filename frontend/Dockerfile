FROM public.ecr.aws/docker/library/node:latest

WORKDIR /app
COPY . .
RUN npm install

CMD ["npm", "start"]