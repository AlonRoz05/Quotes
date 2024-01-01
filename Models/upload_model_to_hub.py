from transformers import AutoModelForSeq2SeqLM, AutoTokenizer, pipeline

model_dir = "Models/Quotes-V2-model"

tokenizer = AutoTokenizer.from_pretrained(model_dir)
model = AutoModelForSeq2SeqLM.from_pretrained(model_dir)

pipe = pipeline("text2text-generation", model=model, tokenizer=tokenizer)

print(pipe("Write a motivational quote that: inspiration;motivation;positivity;ambition;focus describes it best."))

# model.push_to_hub("Quotes-V2")
# tokenizer.push_to_hub