# syntax=docker/dockerfile:1

# Set the CUDA version to install
ARG CUDA_TAG=12.4.1-devel-ubuntu22.04

# Set the Python version to install
ARG PYTHON_VERSION=3.12

# Install Poetry and setup final image on top of the CUDA Python image
FROM ismailbouajaja/cuda-python:${CUDA_TAG}-python${PYTHON_VERSION}

# Set the Poetry version to install
ARG POETRY_VERSION=1.8.*
ARG PYTHONDONTWRITEBYTECODE=1
ARG PYTHONUNBUFFERED=1

# Set the CUDA Docker architecture
ARG CUDA_DOCKER_ARCH=all

# Set the CMake arguments to build llama_cpp with hardware acceleration
ARG CMAKE_ARGS="-DLLAMA_CUDA=on"

# Set environment variables for llama_cpp and Python
ENV CMAKE_ARGS=${CMAKE_ARGS} \
    POETRY_VERSION=${POETRY_VERSION} \
    PYTHONDONTWRITEBYTECODE=${PYTHONDONTWRITEBYTECODE} \
    PYTHONUNBUFFERED=${PYTHONUNBUFFERED}

# Create a directory for the application
WORKDIR /app/code

# Upgrade pip, setuptools, and wheel to the latest versions
RUN pip install --upgrade pip setuptools wheel

# Install and configure poetry
RUN pip install "poetry==$POETRY_VERSION"
RUN poetry config virtualenvs.create false

# Copy Poetry files and install dependencies
COPY code/pyproject.toml code/poetry.lock* ./
RUN poetry install --no-root

# Copy the code directory contents into the container at /app/code
COPY code ./

# Expose the port for the container
EXPOSE 8000

# Set the entrypoint for the container
ENTRYPOINT ["bash", "-c"]

# Set the default command for the container
CMD ["'python -m llama_cpp.server --model /app/data/models/llama-2-7b.Q4_K_M.gguf --n_gpu_layers 99 --host 0.0.0.0 --chat_format llama-2'"]