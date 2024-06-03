# llama-cpp-python-server

This is a Docker image based on `ismailbouajaja/cuda-poetry` that installs `llama-cpp-python[server]` on top.

It provides an easy way to start a llama-cpp-python server.

## Available tags

Tags reflect the image of `ismailbouajaja/cuda-poetry` used and the version of `llama-cpp-python[server]` added on top in the form `${CUDA_TAG}-python${PYTHON_VERSION}-poetry${POETRY_VERSION}-llamacpp${LLAMA_CPP_VERSION}`.

Currently, `latest` corresponds to `12.4.1-cudnn-devel-ubuntu22.04-python3.12-poetry1.8-llamacpp0.2.76`.

Here are the TAGS currently available :
```Python
CUDA_VERSIONS = ["12.3.2", "12.4.1"]
CUDA_CUDNN_OPTIONS = ["", "-cudnn", "-cudnn9"] # -cudnn for 12.4.1; -cudnn9 for 12.3.2
CUDA_TYPES = ["-devel"]
CUDA_OS_OPTIONS = ["-ubuntu20.04", "-ubuntu22.04"]
PYTHON_VERSIONS = ["3.10", "3.11", "3.12"]
POETRY_VERSIONS = ["1.6", "1.7", "1.8"]
LLAMA_CPP_VERSIONS = ["0.2.76"]
```

Other tags will be added later.

## Usage

To use this image from Docker Hub, run the following command :

```bash
docker run --rm -it \
    --gpus all \
    -p 8000:8000 \
    -e USER_UID=$(id -u) \
    -e USER_GID=$(id -g) \
    -v /optional/path/to/config.json:/app/data/config/config.json \
    -v /path/to/models/folder:/app/data/models \
    ismailbouajaja/llama-cpp-python-server
```

This will start a `llama-cpp-python` server based on the provided `config.json` and using the models located in the provided `models` folder.

## Clone repository

To clone the github repository, follow these steps :

1. Clone the repository:
    ```bash
    git clone https://github.com/bouajajais/llama-cpp-python-server.git
    ```

2. Navigate to the project directory:
    ```bash
    cd llama-cpp-python-server
    ```

### Build and run the Dockerfile
2. Build the Docker image using the provided Dockerfile:
    ```bash
    docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t llama-cpp-python-server .
    ```

    The `docker build` command accepts the following arguments:
    - `ARG CUDA_TAG=12.4.1-cudnn-devel-ubuntu22.04`: The CUDA base image tag.
    - `ARG PYTHON_VERSION=3.12`: The Python version to install.
    - `ARG POETRY_VERSION=1.8`: The Poetry version to install.
    - `ARG LLAMA_CPP_PYTHON_VERSION=0.2.76`: The version of `llama-cpp-python[server]` to install.
    - `ARG CMAKE_ARGS="-DLLAMA_CUDA=on"`: Options for installing `llama-cpp-python[server]`.

3. Run the Docker container:
    ```bash
    docker run --rm -it \
        --gpus all \
        -p 8000:8000 \
        -e USER_UID=$(id -u) \
        -e USER_GID=$(id -g) \
        -v /optional/path/to/config.json:/app/data/config/config.json \
        -v /path/to/models/folder:/app/data/models \
        llama-cpp-python-server
    ```

### Docker compose up
2. Create a `.compose.env` file next to the file `compose.yaml` and define the following environment variables inside :
    ```bash
    CONFIG_PATH=/optional/path/to/config.json
    MODELS_PATH=/path/to/models/folder
    ```

3. Run the following commands :
    ```bash
    chmod +x ./set_user_guid.sh
    ./set_user_guid.sh .compose.env
    docker compose --env-file .compose.env up --build
    ```

## Config file

The `config.json` file is defined by `llama-cpp-python[server]`.

## Contributing

Contributions are welcome! If you have any suggestions, bug reports, or feature requests, please open an issue or submit a pull request.