import textwrap
from PIL import Image, ImageDraw, ImageFont

def generate_image(text):
    img = Image.open(f"Imgs/Upliftweet_Background.png")
    font = ImageFont.truetype("Fonts/InstagramSansBold.ttf", 55)

    img_width = img.size[0]
    d = ImageDraw.Draw(img)
    para = textwrap.wrap(text, width=35)

    text_height, pad = 350, 1
    for line in para:
        _, _, w, h = d.textbbox(xy=(0,0), text=line, font=font)
        d.text(((img_width - w) / 2, text_height), line, font=font, fill=(255, 255, 255))
        text_height += h + pad

    img.save('post.png')
