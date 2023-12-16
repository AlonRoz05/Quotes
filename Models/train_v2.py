from datasets import load_from_disk, load_metric
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, Seq2SeqTrainingArguments, Seq2SeqTrainer, DataCollatorForSeq2Seq

import os
import nltk
import logging
import argparse
import numpy as np

nltk.download("punkt")

bleu_metric = load_metric("bleu")
meteor_metric = load_metric("meteor")
rouge_metric = load_metric("rouge")

def compute_metrics(eval_pred):
    predictions, labels = eval_pred

    decoded_preds = tokenizer.batch_decode(predictions, skip_special_tokens=True)
    labels = np.where(labels != -100, labels, tokenizer.pad_token_id)
    decoded_labels = tokenizer.batch_decode(labels, skip_special_tokens=True)

    bleu_score = bleu_metric.compute(predictions=decoded_preds, references=[decoded_labels])
    meteor_score = meteor_metric.compute(predictions=decoded_preds, references=[decoded_labels])
    rouge_score = rouge_metric.compute(predictions=decoded_preds, references=[decoded_labels])

    prediction_lens = [np.count_nonzero(pred != tokenizer.pad_token_id) for pred in predictions]

    return {
        "bleu": round(bleu_score["bleu"], 4),
        "meteor": round(meteor_score["meteor"], 4),
        "rouge": round(rouge_score["rouge1"], 4),
        "gen_len": round(np.mean(prediction_lens), 4),
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    # hyperparameters are passed as command-line arguments to the script.
    parser.add_argument("--model-name", type=str)

    parser.add_argument("--learning-rate", type=str, default=5e-5)
    parser.add_argument("--epochs", type=int, default=3)
    parser.add_argument("--train-batch-size", type=int, default=2)
    parser.add_argument("--eval-batch-size", type=int, default=8)
    parser.add_argument("--evaluation-strategy", type=str, default="epoch")
    parser.add_argument("--save-strategy", type=str, default="no")
    parser.add_argument("--save-steps", type=int, default=500)

    # Data, model, and output directories
    parser.add_argument("--output-data-dir", type=str, default=os.environ["SM_OUTPUT_DATA_DIR"])
    parser.add_argument("--model-dir", type=str, default=os.environ["SM_MODEL_DIR"])
    parser.add_argument("--train-dir", type=str, default=os.environ["SM_CHANNEL_TRAIN"])
    parser.add_argument("--valid-dir", type=str, default=os.environ["SM_CHANNEL_VALID"])

    args, _ = parser.parse_known_args()

    # load datasets
    train_dataset = load_from_disk(args.train_dir)
    valid_dataset = load_from_disk(args.valid_dir)

    logger = logging.getLogger(__name__)
    logger.info(f"training set: {train_dataset}")
    logger.info(f"validation set: {valid_dataset}")
    
    model = AutoModelForSeq2SeqLM.from_pretrained(args.model_name)
    tokenizer = AutoTokenizer.from_pretrained(args.model_name)
    
    data_collator = DataCollatorForSeq2Seq(tokenizer=tokenizer, model=model)
    
    training_args = Seq2SeqTrainingArguments(
        output_dir = args.model_dir,
        num_train_epochs = args.epochs,
        per_device_train_batch_size = args.train_batch_size,
        per_device_eval_batch_size = args.eval_batch_size,
        save_strategy = args.save_strategy,
        save_steps=args.save_steps,
        evaluation_strategy = args.evaluation_strategy,
        logging_dir=f"{args.output_data_dir}/logs",
        learning_rate = float(args.learning_rate),
        predict_with_generate = True,
        load_best_model_at_end = True,
        fp16 = True,
    )

    trainer = Seq2SeqTrainer(
        model = model,
        args = training_args,
        tokenizer=tokenizer,
        train_dataset = train_dataset,
        eval_dataset = valid_dataset,
        data_collator=data_collator,
        compute_metrics = compute_metrics,
    )

    trainer.train()

    trainer.save_model(args.model_dir)
