# clone the vue frontend repo, install dependencies, build the dist folder

# needs to get the git token from the docker build command (see docker-compose.yml)

#### Stage 1: ####

# Clone your repository
From alpine/git as clone
WORKDIR /app
ARG GIT_TOKEN
RUN git clone https://${GIT_TOKEN}@github.com/TimoWacke/loyalty-vue3-frontend.git

#### Stage 2: ####

# Install dependencies and build the dist folder
FROM node:14
WORKDIR /app/loyalty-vue3-frontend
COPY --from=clone /app/loyalty-vue3-frontend .
RUN npm install

# Build the dist folder
# export outputs to log file

# make directory for dist folder
RUN mkdir /app/dist
RUN npm run build > /app/dist/build.log
RUN ls -la /app/dist