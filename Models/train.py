from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, Seq2SeqTrainingArguments, Seq2SeqTrainer, DataCollatorForSeq2Seq

import nltk
import evaluate
import numpy as np

from nltk.tokenize import sent_tokenize

nltk.download("punkt")

metric = evaluate.load("rouge")

model_id = 'google/flan-t5-base'

tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForSeq2SeqLM.from_pretrained(model_id)

# Load the data
train_dataset = load_dataset("csv", data_files="Data/Old_dataset/train_quotes_dataset.csv", sep=",")
test_dataset = load_dataset("csv", data_files="Data/Old_dataset/test_quotes_dataset.csv", sep=",")

# preprocess function
def preprocess_function(sample, padding="max_length"):
    inputs = ["Write a motivational quote about: " + item for item in sample["tags"]]
    model_inputs = tokenizer(inputs, max_length = 441, padding=padding, truncation=True)

    labels = tokenizer(text_target=sample["quote"], max_length = 351, padding=padding, truncation=True)

    if padding == "max_length":
        labels["input_ids"] = [
            [(l if l != tokenizer.pad_token_id else -100) for l in label] for label in labels["input_ids"]
        ]

    model_inputs["labels"] = labels["input_ids"]
    return model_inputs

tokenized_train_dataset = train_dataset.map(preprocess_function, batched=True, remove_columns=["index", "quote", "tags"])
tokenized_test_dataset = test_dataset.map(preprocess_function, batched=True, remove_columns=["index", "quote", "tags"])

data_collator = DataCollatorForSeq2Seq(tokenizer,
                                       model = model, 
                                       label_pad_token_id = -100, 
                                       pad_to_multiple_of = 8)

# Compute metrics function
def postprocess_text(preds, labels):
    preds = [pred.strip() for pred in preds]
    labels = [label.strip() for label in labels]

    preds = ["\n".join(sent_tokenize(pred)) for pred in preds]
    labels = ["\n".join(sent_tokenize(label)) for label in labels]

    return preds, labels

def compute_metrics(eval_preds, tokenizer):
    preds, labels = eval_preds
    if isinstance(preds, tuple):
        preds = preds[0]

    decoded_preds = tokenizer.batch_decode(preds, skip_special_tokens=True)

    labels = np.where(labels != -100, labels, tokenizer.pad_token_id)
    decoded_labels = tokenizer.batch_decode(labels, skip_special_tokens=True)

    decoded_preds, decoded_labels = postprocess_text(decoded_preds, decoded_labels)

    result = metric.compute(predictions=decoded_preds, references=decoded_labels, use_stemmer=True)
    result = {k: round(v * 100, 4) for k, v in result.items()}

    prediction_lens = [np.count_nonzero(pred != tokenizer.pad_token_id) for pred in preds]
    result["gen_len"] = np.mean(prediction_lens)
    return result

data_collator = DataCollatorForSeq2Seq(
    tokenizer,
    model = model,
    label_pad_token_id = -100,
    pad_to_multiple_of = 8
)

# Fine tune the model
args = Seq2SeqTrainingArguments(
    output_dir = "test",
    evaluation_strategy = "epoch",
    save_strategy = "epoch",
    weight_decay = 0.01,
    learning_rate = 5e-5,
    save_total_limit = 2,
    num_train_epochs = 10,
    per_device_train_batch_size = 16,
    per_device_eval_batch_size = 16,
    load_best_model_at_end = True,
    predict_with_generate = True,
    fp16 = False,
    push_to_hub = True,
    hub_model_id = "QuoteVibes_Model_Trained"
)

trainer = Seq2SeqTrainer(
    model = model,
    args = args,
    train_dataset = tokenized_train_dataset["train"],
    eval_dataset = tokenized_test_dataset["train"],
    compute_metrics = compute_metrics,
)

trainer.train()

trainer.push_to_hub("End of training")

trainer.save_model("Models")
tokenizer.save_pretrained("Tokenizer")

model.push_to_hub("QuoteVibes_Model_Trained")
tokenizer.push_to_hub("QuoteVibes_Model_Trained")
