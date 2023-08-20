import postGen

import random

from instagrapi import Client
from instagrapi.types import Media, Story, UserShort

captions = [
    "If this quote speaks your truth, show it some love with a like!",
    "Tap that like button if this resonates with you!",
    "Agree with this? Double-tap that like button! 👍",
    "Hit like if you're feeling inspired by this quote!",
    "Feeling motivated? Give us a thumbs up! 👊",
    "Give a thumbs up if you're embracing positivity today!",
    "Like if you're ready to tackle your goals head-on! 🚀",
    "Raise your hand with a like if you're chasing your dreams!",
    "If this quote speaks to you, a like is all we need!",
    "Agree with this mindset? Hit that like button!",
    "Let's spread positivity - like if you're on board! 🌈",
    "If you're all about growth and inspiration, drop a like! 🌱",
    "Feeling the motivation? Show it with a quick like! 🔥",
    "Who's ready to conquer challenges? Like if it's you! 💪",
    "Let's make the world brighter - like if you're in!",
    "If you're all about pushing limits, drop that like! 🚀",
    "Join the positivity train - a like shows you're on board! 🚂",
]

cl = Client()
cl.login("login", "password")

Media = cl.photo_upload(
    path="photo.jpg",
    caption=random.choice(captions),
    extra_data={
        "like_and_view_counts_disabled": False,
        "disable_comments": False,
    }
)
