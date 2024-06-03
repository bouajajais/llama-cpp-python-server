import subprocess
import concurrent.futures
from itertools import product

REPOSITORY = "ismailbouajaja"
IMAGE_NAME = "llama-cpp-python-server"
CUDA_VERSIONS = ["12.3.2", "12.4.1"]
CUDA_CUDNN_OPTIONS = ["", "-cudnn", "-cudnn9"] # -cudnn for 12.4.1; -cudnn9 for 12.3.2
CUDA_TYPES = ["-devel"] # -base, -runtime, -devel
CUDA_OS_OPTIONS = ["-ubuntu22.04"]
PYTHON_VERSIONS = ["3.12"]
POETRY_VERSIONS = ["1.8"]
LLAMA_CPP_PYTHON_VERSIONS = ["0.2.76"]

VERBOSE = True

def build_and_push_image(image_name: str, tag: str, repository: str, **args: dict[str, str]):
    stdout = None if VERBOSE else subprocess.DEVNULL
    stderr = None if VERBOSE else subprocess.DEVNULL
    try:
        # Build the Docker image
        print(f"Building {IMAGE_NAME}:{tag}...")
        args = " ".join([f"--build-arg {key}={value}" for key, value in args.items()])
        build_command = f"docker build {args} -t {image_name}:{tag} ."
        subprocess.run(build_command, shell=True, check=True, stdout=stdout, stderr=stderr)

        # Tag the Docker image
        tag_command = f"docker tag {image_name}:{tag} {repository}/{image_name}:{tag}"
        subprocess.run(tag_command, shell=True, check=True, stdout=stdout, stderr=stderr)

        # Push the Docker image
        print(f"Pushing {IMAGE_NAME}:{tag} to {REPOSITORY}...")
        push_command = f"docker push {repository}/{image_name}:{tag}"
        subprocess.run(push_command, shell=True, check=True, stdout=stdout, stderr=stderr)

        print(f"Image {IMAGE_NAME}:{tag} successfully built and pushed to {REPOSITORY}...")
        
        # Remove the tagged Docker image
        print("Removing the tagged Docker image...")
        remove_command = f"docker rmi {repository}/{image_name}:{tag}"
        subprocess.run(remove_command, shell=True, check=True, stdout=stdout, stderr=stderr)
        print(f"Image {repository}/{image_name}:{tag} successfully removed...")
        
        # Remove the local Docker image
        print("Removing the local Docker image...")
        remove_command = f"docker rmi {image_name}:{tag}"
        subprocess.run(remove_command, shell=True, check=True, stdout=stdout, stderr=stderr)
        print(f"Image {repository}/{image_name}:{tag} successfully removed...")
        
    except Exception as e:
        print(f"Error building and pushing image {IMAGE_NAME}:{tag} to {REPOSITORY}: {e}")

def main():
    # with concurrent.futures.ThreadPoolExecutor() as executor:
    #     futures = []
        for cuda_version, cudnn_option, cuda_type, cuda_os, python_version, poetry_version, llama_cpp_version in product(CUDA_VERSIONS, CUDA_CUDNN_OPTIONS, CUDA_TYPES, CUDA_OS_OPTIONS, PYTHON_VERSIONS, POETRY_VERSIONS, LLAMA_CPP_PYTHON_VERSIONS):
            if cuda_version == "12.3.2" and cudnn_option == "-cudnn":
                continue
            if cuda_version == "12.4.1" and cudnn_option == "-cudnn9":
                continue
            cuda_tag = f"{cuda_version}{cudnn_option}{cuda_type}{cuda_os}"
            args = {
                "CUDA_TAG": cuda_tag,
                "PYTHON_VERSION": python_version,
                "POETRY_VERSION": poetry_version,
                "LLAMA_CPP_PYTHON_VERSION": llama_cpp_version,
                "USER_UID": "1000",
                "USER_GID": "1000"
            }
            tag = f"{cuda_tag}-python{python_version}-poetry{poetry_version}-llamacpp{llama_cpp_version}"
            build_and_push_image(IMAGE_NAME, tag, REPOSITORY, **args)
            # futures.append(executor.submit(build_and_push_image, IMAGE_NAME, tag, REPOSITORY, **args))
        
        # Wait for all tasks to complete
        # concurrent.futures.wait(futures)

if __name__ == "__main__":
    main()