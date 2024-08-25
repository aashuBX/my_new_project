# Build stage 
FROM python:3.9.14 AS build

# Setting the working directory
WORKDIR /app

# Defining args 
ARG GIT_USER_NAME
ARG GIT_AUTH_TOKEN

# Copying the requirements.txt file into the working directory
COPY requirements.txt /app  

# Installing dependencies
# RUN sed -i 's|git+https://|git+https://${GIT_USER_NAME}:${GIT_AUTH_TOKEN}@|g' requirements.txt && \
#     pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

RUN sed -i 's|git+https://|git+https://${GIT_USER_NAME}:${GIT_AUTH_TOKEN}@|g' requirements.txt && \
    pip install --upgrade pip && pip install -r requirements.txt


# <-----------------------------------------Next Stage Below------------------------------------------------>

# Final stage
FROM python:3.9.14-slim AS final

# Define the json_log_path & application_log_path below
ENV JSON_LOG_PATH="/extra-01/logs/conversive-button-runtime" \
    APPLICATION_LOG_PATH="/application/logs/conversive-button-runtime"

# Creating a non-root user with a home directory and creating directories to store json logs and application logs
RUN useradd -ms /bin/bash myuser && \
    mkdir -p /app ${JSON_LOG_PATH} ${APPLICATION_LOG_PATH}

# Creating temp directory and setting its ownership to 'myuser'
# RUN mkdir -p /app && chown -R myuser:myuser /app

# Installing packages and changing ownership of directories to 'myuser'
RUN apt-get update && apt-get install libmariadb3 -y && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R myuser:myuser /app ${JSON_LOG_PATH} ${APPLICATION_LOG_PATH}

# Switching to the user 'myuser'
USER myuser

WORKDIR /app

# Copying files from the build stage and changing their ownership to 'myuser'
COPY --chown=myuser:myuser --from=build /usr/local/ /usr/local/
COPY --chown=myuser:myuser . /app

# Setting the PYTHONPATH and other environment variable
ENV PYTHONPATH="$PYTHONPATH:/app" \
    DEBUG="${DEBUG}"

EXPOSE 5008

# Defining cmd for api
# CMD sh -c 'gunicorn --bind 0.0.0.0:5008 --log-level=${DEBUG} \
#     --access-logfile ${APPLICATION_LOG_PATH}/access.log --error-logfile ${APPLICATION_LOG_PATH}/error.log \
#     --log-file ${APPLICATION_LOG_PATH}/gunicorn.log \
#     run:app \
#     --worker-class gevent --timeout 30 --worker-connections 256 --max-requests 1024'

CMD sh -c 'gunicorn --bind 0.0.0.0:5008 --log-level=${DEBUG} \
    --access-logfile ${APPLICATION_LOG_PATH}/access.log --error-logfile ${APPLICATION_LOG_PATH}/error.log \
    --log-file ${APPLICATION_LOG_PATH}/gunicorn.log \
    app:app \
    --worker-class gevent --timeout 30 --worker-connections 256 --max-requests 1024'

# CMD sh -c 'gunicorn --bind 0.0.0.0:5008 --log-level=DEBUG run:app'