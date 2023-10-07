import pandas as pd

import random

from fastapi import FastAPI
import uvicorn

from better_profanity import profanity

from transformers import pipeline

app = FastAPI()

classifier = pipeline("text2text-generation", model="Rozi05/QuoteVibes_Model_Trained")

profanity.load_censor_words()

tags_path = "tags.json"

@app.get("/")
async def return_quote(*, tag: str):
    for i in range(5):
        if i == 0:
            tag_1 = random.choice(pd.read_json(tags_path)["tags"])
            while tag_1 == tag:
                tag_2 = random.choice(pd.read_json(tags_path)["tags"])
            
        if i == 1:
            tag_2 = random.choice(pd.read_json(tags_path)["tags"])
            while tag_2 == tag_1 or tag_2 == tag:
                tag_2 = random.choice(pd.read_json(tags_path)["tags"])
                
        elif i == 2:
            tag_3 = random.choice(pd.read_json(tags_path)["tags"])
            while tag_3 == tag_1 and tag_3 == tag_2 or tag_3 == tag:
                tag_3 = random.choice(pd.read_json(tags_path)["tags"])
        
        elif i == 3:
            tag_4 = random.choice(pd.read_json(tags_path)["tags"])
            while tag_4 == tag_1 and tag_4 == tag_2 and tag_4 == tag_3 or tag_4 == tag:
                tag_4 = random.choice(pd.read_json(tags_path)["tags"])
        
        elif i == 4:
            tag_5 = random.choice(pd.read_json(tags_path)["tags"])
            while tag_5 == tag_1 and tag_5 == tag_2 and tag_5 == tag_3 and tag_5 == tag_4 or tag_5 == tag:
                tag_5 = random.choice(pd.read_json(tags_path)["tags"])

    tags = f"{tag}, {tag_1}, {tag_2}, {tag_3}, {tag_4}, {tag_5}, {tag}"
    if tag == "default":
        tags = f"{tag_1}, {tag_2}, {tag_3}, {tag_4}, {tag_5}"

    models_quote = classifier(tags)

    check_for_profanity = profanity.censor(models_quote[0]["generated_text"])
    test_for_text = models_quote[0]["generated_text"].replace(" ", "x")

    while "*" in check_for_profanity or test_for_text == "xxxxxxxxx":
        models_quote = classifier(tags)

        check_for_profanity = profanity.censor(models_quote[0]["generated_text"])
        test_for_text = models_quote[0]["generated_text"].replace(" ", "x")

    models_quote = models_quote[0]["generated_text"]
    return {"quote": models_quote}


if __name__ == "__main":
    uvicorn.run(app, host="0.0.0.0", port=8000)
