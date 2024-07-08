# Use an official Python runtime as a parent image
FROM python:3.9

# Set the working directory in the container
WORKDIR /app

# Add arguments for the version, project name, and index URL
ARG VERSION
ARG PROJECT_NAME
ARG INDEX_URL

# Create a script to check the version and install it
RUN echo '#!/bin/bash\n' \
         'if pip install ${PROJECT_NAME}==${VERSION} -i ${INDEX_URL} --trusted-host 10.10.1.59; then\n' \
         '  echo "Installed version ${VERSION}"\n' \
         'else\n' \
         '  echo "Version ${VERSION} does not exist, exiting." | tee /error.log\n' \
         '  exit 1\n' \
         'fi\n' \
         > /install.sh && chmod +x /install.sh

# Run the installation script
RUN /install.sh

# Run your application
CMD [ "python3.9", "/usr/local/lib/python3.9/site-packages/${PROJECT_NAME}/main.py"]
