import pandas as pd

import random

from transformers import pipeline, AutoModelForSeq2SeqLM

model_dir = "Rozi05/QuoteVibes_Model_Trained"

loaded_model = AutoModelForSeq2SeqLM.from_pretrained(model_dir)
classifier = pipeline("text2text-generation", model=model_dir)

tags_list = []

for i in range(5):
    if i == 0:
        tag_1 = random.choice(tags_list)
        a = random.choice(tags_list)

    if i == 1:
        while a == tag_1:
            a = random.choice(tags_list)
        tag_2 = a
        
    if i == 2:
        while a == tag_1 or a == tag_2:
            a = random.choice(tags_list)
        tag_3 = a

    if i == 3:
        while a == tag_1 or a == tag_2 or a == tag_3:
            a = random.choice(tags_list)
        tag_4 = a

    if i == 4:
        while a == tag_1 or a == tag_2 or a == tag_3 or a == tag_4:
            a = random.choice(tags_list)
        tag_5 = a

models_quote = classifier(f"{tag_1};{tag_2};{tag_3};{tag_4};{tag_5}")
