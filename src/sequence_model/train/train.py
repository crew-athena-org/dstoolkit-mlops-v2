import argparse
import json
import logging
import pickle
import pathlib
import os
import yaml
from src.sequence_model.common.tokenizer import Tokenizer
from src.sequence_model.common.seq_model import NgramModel
import src.sequence_model.common.mlflow_ext as mlflow

logger = logging.getLogger(__name__)

run_tags = {"model": "sequence_model", "step": "train"}
current_run_id: str = None
parent_run_id: str = None

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Sequence Model")

    parser.add_argument(
        "--dataset_folder", type=str, required=True, default=None, help="train path"
    )

    parser.add_argument(
        "--model_artifacts",
        type=str,
        required=True,
        default=None,
        help="Path to host serialized model components",
    )

    parser.add_argument(
        "--model_config",
        type=str,
        required=True,
        default=None,
        help="model configuration",
    )

    args = parser.parse_args()

    # Load model yaml configuration
    cfg = yaml.safe_load(open(args.model_config))

    logging_cfg = cfg["logging"]
    model_cfg = cfg["model"]
    mlflow_cfg = cfg["mlflow"]

    # Configure logging
    logging.config.dictConfig(logging_cfg)

    # Configure mlflow

    current_run_id, parent_run_id = mlflow.init_run(
        args,
        run_tags,
        job_config=(
            model_cfg  # Concatenate dictionaries of further configuration here
        ),
        mlflow_config=mlflow_cfg,
    )

    # I/O operations

    # Construct output root folders in registration directory
    model_artifacts = pathlib.Path(args.model_artifacts)
    model_root = pathlib.Path(model_artifacts, "model")
    tokenizer_root = pathlib.Path(model_artifacts, "tokenizer")

    # Establish output file paths
    model_path = pathlib.Path(model_root, "model_dict.pkl")
    model_metadata_path = pathlib.Path(model_root, "model_metadata.json")
    tokenizer_path = pathlib.Path(tokenizer_root, "tokenizer.json")

    # Make directories
    pathlib.Path(args.model_artifacts).mkdir(exist_ok=True)
    pathlib.Path(model_root).mkdir(exist_ok=True)
    pathlib.Path(tokenizer_root).mkdir(exist_ok=True)

    # Input paths
    train_data_path = os.path.join(args.dataset_folder, "train.pkl")

    model_uri = f"runs:/{current_run_id}/model"
    model_metadata = {
        "run_id": current_run_id,
        "run_uri": model_uri,
        "training_data_path": train_data_path,
    } | model_cfg
    logger.info(f"run_id :::: {current_run_id}")

    model_metadata = {}
    # Dump metadata
    with open(model_metadata_path, "w") as json_file:
        json.dump(model_metadata, json_file, indent=4)

    # Load data
    with open(train_data_path, "rb") as f:
        train_data = pickle.load(f)

    # Train tokenizer
    logger.info("Training tokenizer.")
    tokenizer = Tokenizer()
    tokenizer.train(corpus=train_data, save_path=tokenizer_path)
    logger.info(f"Vocabularly size: {tokenizer.vocab_size}.")

    logger.info("Tokenizing data.")
    # Tokenize the corpus
    tokenized_data = tokenizer.tokenize(corpus=train_data)

    # Train model
    logger.info("Training model.")
    model = NgramModel(
        max_prior_token_length=model_cfg["max_prior_token_length"],
        max_top_n=model_cfg["max_top_n"],
    )
    model.count(tokenized_data)
    model.train()

    logger.info("Saving model.")
    model.save(model_path)
