import os
from glob import glob
import json
import sys
from typing import Optional

def create_config_file(config_path: str, models_dir: str) -> None:
    if os.path.exists(config_path):
        return
    
    models_paths = glob(f"{models_dir}/*.gguf")
    config = {
        "models": [{
            "model": model_path,
            "model_alias": os.path.basename(model_path).replace('.gguf', '')
        } for model_path in models_paths],
    }
    
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=4)
        
def process_config_file(config_path: str, default_port: int, n_gpu_layers: Optional[int] = None) -> None:
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    config["host"] = "0.0.0.0"
    if "port" not in config:
        config["port"] = default_port
        
    for model_config in config["models"]:
        if "n_gpu_layers" not in model_config and n_gpu_layers is not None:
            model_config["n_gpu_layers"] = n_gpu_layers
    
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=4)

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Usage: python setup_config_file.py <config_path> <models_dir> <default_port>")
        sys.exit(1)
    
    config_path = sys.argv[1]
    models_dir = sys.argv[2]
    default_port = sys.argv[3]
    
    create_config_file(config_path, models_dir)
    process_config_file(config_path, default_port)