from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, Seq2SeqTrainingArguments, Seq2SeqTrainer, DataCollatorForSeq2Seq

from helper_fn import compute_metrics

model_id = 'google/flan-t5-base'

tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForSeq2SeqLM.from_pretrained(model_id)

# Load the data
train_dataset = load_dataset("csv", data_files="Data/train_quotes_dataset.csv", sep=",")
test_dataset = load_dataset("csv", data_files="Data/test_quotes_dataset.csv", sep=",")

# preprocess function
def preprocess_function(sample, padding="max_length"):
    inputs = ["Generate motivational quote about: " + item for item in sample["tags"]]
    model_inputs = tokenizer(inputs, max_length=441, padding=padding, truncation=True)

    labels = tokenizer(text_target=sample["quote"], max_length=351, padding=padding, truncation=True)

    if padding == "max_length":
        labels["input_ids"] = [
            [(l if l != tokenizer.pad_token_id else -100) for l in label] for label in labels["input_ids"]
        ]

    model_inputs["labels"] = labels["input_ids"]
    return model_inputs

tokenized_train_dataset = train_dataset.map(preprocess_function, batched=True, remove_columns=["index", "quote", "tags"])
tokenized_test_dataset = test_dataset.map(preprocess_function, batched=True, remove_columns=["index", "quote", "tags"])

data_collator = DataCollatorForSeq2Seq(tokenizer,
                                       model=model, 
                                       label_pad_token_id= -100, 
                                       pad_to_multiple_of=8)

# Fine tune the model
args = Seq2SeqTrainingArguments(
    output_dir="test",
    evaluation_strategy = "epoch",
    save_strategy="epoch",
    weight_decay = 0.01,
    learning_rate = 5e-5,
    save_total_limit = 2,
    num_train_epochs = 10,
    per_device_train_batch_size = 8,
    per_device_eval_batch_size = 8,
    metric_for_best_model="overall_f1",
    load_best_model_at_end=True,
    predict_with_generate = True,
    fp16 = True,
)

trainer = Seq2SeqTrainer(
    model=model,
    args=args,
    train_dataset=tokenized_train_dataset,
    eval_dataset=tokenized_test_dataset,
    compute_metrics=compute_metrics,
)

trainer.train()
trainer.evaluate()
trainer.save_model("Models")
