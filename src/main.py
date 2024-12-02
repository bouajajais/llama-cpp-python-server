import subprocess
from setup_config_file import create_config_file, process_config_file

CONFIG_PATH = "/app/config/config.json"
MODELS_DIR = "/app/data/models"
DEFAULT_PORT = 8000
DEFAULT_N_GPU_LAYERS = 99

def start_server():
    create_config_file(config_path=CONFIG_PATH, models_dir=MODELS_DIR)
    process_config_file(config_path=CONFIG_PATH, default_port=DEFAULT_PORT, n_gpu_layers=DEFAULT_N_GPU_LAYERS)
    command = f"python -m llama_cpp.server --config_file {CONFIG_PATH}"
    subprocess.run(command, shell=True)

if __name__ == "__main__":
    start_server()