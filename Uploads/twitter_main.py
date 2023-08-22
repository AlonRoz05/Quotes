import pandas as pd

import random

from transformers import pipeline

model_dir = "Rozi05/QuoteVibes_Model_Trained"

classifier = pipeline("text2text-generation", model=model_dir)

df_train = pd.read_csv("Data/train_quotes_dataset.csv")
df_test= pd.read_csv("Data/test_quotes_dataset.csv")

models_quote = classifier(random.choice(df_train.tags) if random.random() > 0.5 else random.choice(df_test.tags))
