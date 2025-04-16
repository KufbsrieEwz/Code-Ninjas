# How to Run

### pre-reqs
- node
- docker

So has of now the method of running is sort of untested because I've been having issues with my docker install but ideally it'll be as simple as running the following commands in a terminal:

1. npm install 
2. docker-compose build --no-cache
3. docker-compose up

the first command will take all the code in the directory and build the program within a docker container the second command will run the container 

If like me you are having issues with your docker install you can do the following:

1. npm install 
2. docker-compose build --no-cache
3. docker-compose up -d 
4. node server.js

this is like the first method but we run the server code manually 