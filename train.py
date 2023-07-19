import torch

from datasets import load_dataset, concatenate_datasets
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, Seq2SeqTrainingArguments, Seq2SeqTrainer, DataCollatorForSeq2Seq

import helper_fn

# Set the device to GPU if available
device = "cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu"
torch.set_default_device(device)

# Hyperparameters
model_id = 'google/flan-t5-base'
batch_size = 8
num_epochs = 10

tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForSeq2SeqLM.from_pretrained(model_id)

# Load the data
dataset = load_dataset("csv", data_files="Data/quotes.csv", sep=",")
dataset = dataset.train_test_split(test_size=0.2, shuffle=True)

tokenized_inputs = concatenate_datasets(dataset["train"], dataset["test"]).map(lambda x: tokenizer(x["Tags"], truncation=True), batched=True, remove_columns=["Tags", "Quote"])
max_source_length = max([len(x) for x in tokenized_inputs["input_ids"]]) # fix

tokenized_targets = concatenate_datasets(dataset["train"], dataset["test"]).map(lambda x: tokenizer(x["Quote"], truncation=True), batched=True, remove_columns=["Tags", "Quote"])
max_target_length = max([len(x) for x in tokenized_targets["input_ids"]]) # fix

tokenized_dataset = dataset.map(helper_fn.preprocess_function, batched=True, remove_columns=["dialogue", "summary", "id"])
data_collator = DataCollatorForSeq2Seq(tokenizer, model=model, label_pad_token_id=-100, pad_to_multiple_of=8 if device == "cuda" else None)

# Fine tune the model
args = Seq2SeqTrainingArguments(
    output_dir="test",
    evaluation_strategy = "epoch",
    save_strategy="epoch",
    weight_decay = 0.01,
    learning_rate = 5e-5,
    save_total_limit = 2,
    num_train_epochs = num_epochs,
    per_device_train_batch_size = batch_size,
    per_device_eval_batch_size = batch_size,
    metric_for_best_model="overall_f1",
    load_best_model_at_end=True,
    predict_with_generate = True,
    fp16 = True,
    push_to_hub = True
)

trainer = Seq2SeqTrainer(
    model = model,
    args = args,
    train_dataset = tokenized_dataset["train"],
    eval_dataset = tokenized_dataset["test"],
    compute_metrics = helper_fn.compute_metrics,
)

trainer.train()
trainer.evaluate()
trainer.save_model("Models")
