### clones the nodejs loyalty backend github repo, installs dependencies, and starts the server

# Stage 1: Clone the repository
FROM alpine/git as clone
WORKDIR /app
ARG GIT_TOKEN
RUN git clone https://${GIT_TOKEN}@github.com/TimoWacke/loyalty-node-backend.git

# Stage 2: Install dependencies and start the server
FROM node:14
WORKDIR /app/loyalty-node-backend
COPY --from=clone /app/loyalty-node-backend .

# Update the below line with the correct folder containing the package.json if needed
WORKDIR /app/loyalty-node-backend 
RUN npm install

# Set the correct command to start your server
CMD ["npm", "start"]
EXPOSE 3030
