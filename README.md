# The One Ring framework

- This is the aggregarion of all other research and education containerized environments. Using multiple Docker compose files, this framework aims to 
provide users with a dynamic setup that can be quickly extended based on their own teach/learning/researching progress. 

### Warning

- If you clone into a Windows environment, makes sure that your git is set to keep `LF`:

~~~
git config --global core.autocrlf false 
git clone -b csc331 https://github.com/ngo-classes/the-one-ring
cd the-one-ring
~~~

### Building the base images

- You should build the images in the following order:
- Build the specific bases depending on your courses need:

- CSC331

~~~
docker compose -f docker-compose.bases.yml build csc331base --no-cache
~~~
