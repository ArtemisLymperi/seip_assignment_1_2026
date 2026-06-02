#base image
FROM node:18-alpine

#set working directory
WORKDIR /app

#copy dependency files for caching optimization
COPY package*.json ./

#install dependencies
RUN npm install

#copy the remaining source code
COPY . .

#document the intended container port
EXPOSE 3000

#start the application
CMD ["node", "server.js"]