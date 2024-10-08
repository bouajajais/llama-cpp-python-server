# syntax=docker/dockerfile:1

# Set the CUDA version to install
ARG CUDA_TAG=12.6.0-cudnn-devel-ubuntu22.04

# Set the Python version to install
ARG PYTHON_VERSION=3.12

# Set the Poetry version to install
ARG POETRY_VERSION=1.8

# Install Poetry and setup final image on top of the CUDA Python image
FROM ismailbouajaja/cuda-poetry:${CUDA_TAG}-python${PYTHON_VERSION}-poetry${POETRY_VERSION}

#### System-wide setup
## Put custom system-wide setup here

## End of custom system-wide setup
#### End of system-wide setup

#### User-specific setup

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000

# Create the user and group with the specified UID/GID
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    # Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Install necessary tools for building su-exec
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gcc \
    libc-dev \
    make

# Download, build, and install su-exec
RUN SU_EXEC_VERSION=0.2 \
    && curl -o /usr/local/bin/su-exec.c -L https://raw.githubusercontent.com/ncopa/su-exec/v${SU_EXEC_VERSION}/su-exec.c \
    && gcc -Wall -Werror -O2 /usr/local/bin/su-exec.c -o /usr/local/bin/su-exec \
    && chown root:root /usr/local/bin/su-exec \
    && chmod 0755 /usr/local/bin/su-exec \
    && rm /usr/local/bin/su-exec.c

# Switch to the ${USERNAME}
USER ${USERNAME}

# Copy the entrypoint script
COPY --chown=${USERNAME}:${USERNAME} entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

## Put custom user-specific setup here
# Do not forget to chown the files to the ${USERNAME} user
# Example:
# COPY --chown=${USERNAME}:${USERNAME} source destination

# Create a directory for the application
WORKDIR /app/code

# Desired version of llama-cpp-python
ARG LLAMA_CPP_PYTHON_VERSION=0.2.89

# Set the CMake arguments to build llama_cpp with hardware acceleration
ARG CMAKE_ARGS="-DGGML_CUDA=on -DLLAVA_BUILD=off"

# Set the CUDA Docker architecture
ARG CUDA_DOCKER_ARCH=all

# Set environment variables for llama_cpp
ENV LLAMA_CPP_PYTHON_VERSION=${LLAMA_CPP_PYTHON_VERSION} \
    CMAKE_ARGS=${CMAKE_ARGS} \
    FORCE_CMAKE=1

# Copy Poetry files and install dependencies
COPY --chown=${USERNAME}:${USERNAME} code/pyproject.toml code/poetry.lock* ./
RUN poetry config virtualenvs.path /home/${USERNAME}/.venvs \
    && poetry add llama-cpp-python[server]@${LLAMA_CPP_PYTHON_VERSION} \
    && poetry install --no-root

# Get the path to the Poetry virtual environment's Python executable
RUN PYTHON_PATH=$(poetry env info --executable) \
    && echo "PYTHON_PATH=${PYTHON_PATH}" >> ~/.python_path
USER root
RUN cat /home/${USERNAME}/.python_path >> /etc/environment
USER ${USERNAME}

# Copy the code directory contents into the container at /app/code
COPY --chown=${USERNAME}:${USERNAME} code ./

## End of custom user-specific setup

#### End of user-specific setup

# Switch back to the root user to run the entrypoint
USER root

# Expose the port for the container
EXPOSE 8000

# Set the entrypoint to adjust UID/GID at runtime and execute the command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command for the container
CMD ["poetry", "run", "python", "main.py"]