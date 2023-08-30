import pandas as pd

import postGen

import tweepy
import random

from transformers import pipeline

from better_profanity import profanity

from twitter_data import bearer_token, API_key, API_secret, access_token, access_token_secret, captions

model_dir = "Rozi05/QuoteVibes_Model_Trained"

classifier = pipeline("text2text-generation", model=model_dir)

profanity.load_censor_words()

client = tweepy.Client(bearer_token, API_key, API_secret, access_token, access_token_secret)

auth = tweepy.OAuth1UserHandler(API_key, API_secret, access_token, access_token_secret)
api = tweepy.API(auth)

tags_path = "Data/tags.json"

tag_1 = ""
tag_2 = ""
tag_3 = ""
tag_4 = ""
tag_5 = ""

for i in range(5):
    if i == 0:
        tag_1 = random.choice(pd.read_json(tags_path)["tags"])
    
    elif i == 1:
        tag_2 = random.choice(pd.read_json(tags_path)["tags"])
        while tag_2 == tag_1:
            tag_2 = random.choice(pd.read_json(tags_path)["tags"])
            
    elif i == 2:
        tag_3 = random.choice(pd.read_json(tags_path)["tags"])
        while tag_3 == tag_1 and tag_3 == tag_2:
            tag_3 = random.choice(pd.read_json(tags_path)["tags"])
    
    elif i == 3:
        tag_4 = random.choice(pd.read_json(tags_path)["tags"])
        while tag_4 == tag_1 and tag_4 == tag_2 and tag_4 == tag_3:
            tag_4 = random.choice(pd.read_json(tags_path)["tags"])
    
    elif i == 4:
        tag_5 = random.choice(pd.read_json(tags_path)["tags"])
        while tag_5 == tag_1 and tag_5 == tag_2 and tag_5 == tag_3 and tag_5 == tag_4:
            tag_5 = random.choice(pd.read_json(tags_path)["tags"])

tags = f"{tag_1};{tag_2};{tag_3};{tag_4};{tag_5}"

models_quote = classifier(tags)

check_for_profanity = profanity.censor(models_quote[0]["generated_text"])
test_for_text = models_quote[0]["generated_text"].replace(" ", "x")

while "*" in check_for_profanity or test_for_text == "xxxxxxxxx":
    models_quote = classifier(tags)

    check_for_profanity = profanity.censor(models_quote[0]["generated_text"])
    test_for_text = models_quote[0]["generated_text"].replace(" ", "x")

models_quote = models_quote[0]["generated_text"]

if random.random() <= 0.2:
    postGen.generate_image(models_quote)

    media_id = api.media_upload(filename="post.png").media_id_string
    client.create_tweet(text=random.choice(captions),media_ids=[media_id])
    print(f"Succesfuly tweeted an image with this quote: {models_quote}, from this input: {tags}")

else:
    client.create_tweet(text=models_quote)
    print(f"Succesfuly tweeted this quote: {models_quote}, from this input: {tags}")
