# syntax=docker/dockerfile:1

# Desired version of llama-cpp-python
ARG LLAMA_CPP_PYTHON_VERSION=0.3.2

# Set the CUDA version to install
ARG CUDA_TAG=12.6.2-cudnn-devel-ubuntu22.04

# Set the Poetry version to install
ARG POETRY_VERSION=1.8

# Set the Python version to install
ARG PYTHON_VERSION=3.10

#################### DEV IMAGE ####################

FROM ismailbouajaja/cuda-poetry:nvidia__cuda__${CUDA_TAG}--poetry__${POETRY_VERSION}--python__${PYTHON_VERSION}--dev AS dev

ARG LLAMA_CPP_PYTHON_VERSION

# Set the CMake arguments to build llama_cpp with hardware acceleration
ARG CMAKE_ARGS="-DGGML_CUDA=on -DLLAVA_BUILD=off"

# Set the CUDA Docker architecture
ARG CUDA_DOCKER_ARCH=all

# Switch to user
USER user

# Set environment variables for llama_cpp
ENV LLAMA_CPP_PYTHON_VERSION=${LLAMA_CPP_PYTHON_VERSION} \
    CMAKE_ARGS=${CMAKE_ARGS} \
    FORCE_CMAKE=1

# Change the working directory to /app/src
WORKDIR /app/src

# Copy Poetry files and install dependencies
COPY --chown=user:user ./src/pyproject.toml ./src/poetry.lock* ./

# install dependencies
RUN poetry add llama-cpp-python[server]@${LLAMA_CPP_PYTHON_VERSION} \
    && poetry install --no-root

# Get the path to the Poetry virtual environment's Python executable
RUN PYTHON_PATH=$(poetry env info --executable) \
    && echo "PYTHON_PATH=${PYTHON_PATH}" >> /home/user/.python_path
USER root
RUN cat /home/user/.python_path >> /etc/environment

EXPOSE 8000

#################### PROD IMAGE ####################

FROM ismailbouajaja/cuda-poetry:nvidia__cuda__${CUDA_TAG}--poetry__${POETRY_VERSION}--python__${PYTHON_VERSION} AS prod

ARG LLAMA_CPP_PYTHON_VERSION

# Set the CMake arguments to build llama_cpp with hardware acceleration
ARG CMAKE_ARGS="-DGGML_CUDA=on -DLLAVA_BUILD=off"

# Set the CUDA Docker architecture
ARG CUDA_DOCKER_ARCH=all

# Set environment variables for llama_cpp
ENV LLAMA_CPP_PYTHON_VERSION=${LLAMA_CPP_PYTHON_VERSION} \
    CMAKE_ARGS=${CMAKE_ARGS} \
    FORCE_CMAKE=1

# Change the working directory to /app/src
WORKDIR /app/src

# Copy Poetry files and install dependencies
COPY --chown=user:user ./src/pyproject.toml ./src/poetry.lock* ./

# install dependencies
RUN poetry add llama-cpp-python[server]@${LLAMA_CPP_PYTHON_VERSION} \
    && poetry install --no-root

# Change the working directory to /app
WORKDIR /app

# Copy the directory contents into the container at /app
COPY --chown=user:user ./ ./

# Change the working directory to /app
WORKDIR /app/src

EXPOSE 8000

# Set the default command for the container
CMD ["poetry", "run", "python", "main.py"]