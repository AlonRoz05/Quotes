import pandas as pd

import postGen

import tweepy
import random

from transformers import pipeline

from better_profanity import profanity

from twitter_keys import bearer_token, API_key, API_secret, access_token, access_token_secret

model_dir = "Rozi05/QuoteVibes_Model_Trained"

classifier = pipeline("text2text-generation", model=model_dir)

df_train = pd.read_csv("Data/Old_dataset/train_quotes_dataset.csv")
df_test= pd.read_csv("Data/Old_dataset/test_quotes_dataset.csv")

profanity.load_censor_words()

client = tweepy.Client(bearer_token, API_key, API_secret, access_token, access_token_secret)

auth = tweepy.OAuth1UserHandler(API_key, API_secret, access_token, access_token_secret)
api = tweepy.API(auth)

models_quote = classifier(random.choice(df_train.tags) if random.random() > 0.5 else random.choice(df_test.tags))

check_for_profanity = profanity.censor(models_quote[0]["generated_text"])
test_for_text = models_quote[0]["generated_text"].replace(" ", "x")

while "*" in check_for_profanity or test_for_text == "xxxxxxxxx":
    models_quote = classifier(random.choice(df_train.tags) if random.random() > 0.5 else random.choice(df_test.tags))

    check_for_profanity = profanity.censor(models_quote[0]["generated_text"])
    test_for_text = models_quote[0]["generated_text"].replace(" ", "x")

models_quote = models_quote[0]["generated_text"]

if random.random() <= 0.1:
    postGen.generate_image(models_quote)

    media_id = api.media_upload(filename="post.png").media_id_string
    client.create_tweet(media_ids=[media_id])
    print(f"Succesfuly tweeted an image with this quote: {models_quote}")

else:
    client.create_tweet(text=models_quote)
    print(f"Succesfuly tweeted this quote: {models_quote}")
