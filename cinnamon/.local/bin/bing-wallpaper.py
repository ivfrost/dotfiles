#!/usr/bin/env python3

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from urllib.request import urlopen, Request

FEED_URL = 'https://peapix.com/bing/feed?country='
DEFAULT_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:99.0) Gecko/20100101 Firefox/99.0',
}

# Comprehensive animal & wildlife keyword blacklist
EXCLUDED_KEYWORDS = {
    # Mammals
    'bear', 'bears', 'bird', 'birds', 'tiger', 'tigers', 'lion', 'lions', 'cat', 'cats',
    'dog', 'dogs', 'monkey', 'monkeys', 'owl', 'owls', 'wolf', 'wolves', 'fox', 'foxes',
    'whale', 'whales', 'dolphin', 'dolphins', 'fish', 'fishes', 'deer', 'deers', 'elephant',
    'elephants', 'penguin', 'penguins', 'snake', 'snakes', 'frog', 'frogs', 'leopard',
    'leopards', 'cheetah', 'cheetahs', 'giraffe', 'giraffes', 'zebra', 'zebras', 'seal',
    'seals', 'otter', 'otters', 'panda', 'pandas', 'iguana', 'chameleon', 'lizard', 'lizards',
    'eagle', 'eagles', 'hawk', 'hawks', 'flamingo', 'flamingos', 'swan', 'swans', 'duck',
    'ducks', 'goose', 'geese', 'horse', 'horses', 'cow', 'cows', 'sheep', 'goat', 'goats',
    'squirrel', 'squirrels', 'rabbit', 'rabbits', 'hare', 'hares', 'kangaroo', 'kangaroos',
    'koala', 'koalas', 'sloth', 'sloths', 'lemur', 'lemurs', 'insect', 'insects', 'beetle',
    'bison', 'buffalo', 'camel', 'camels', 'hippopotamus', 'hippo', 'hippos', 'rhinoceros',
    'rhino', 'rhinos', 'walrus', 'porpoise', 'jaguar', 'jaguars', 'cougar', 'puma', 'lynx',
    # Birds & Flying
    'parrot', 'parrots', 'macaw', 'pelican', 'heron', 'crane', 'puffins', 'puffin',
    'hummingbird', 'falcon', 'vulture', 'stork', 'cormorant',
    # Aquatic & Marine
    'shark', 'sharks', 'stingray', 'ray', 'jellyfish', 'turtle', 'turtles', 'octopus',
    'squid', 'starfish', 'coral', 'lobster', 'crab', 'crabs', 'seahorse',
    # Reptiles & Amphibians
    'alligator', 'crocodile', 'gecko', 'toad', 'toads', 'salamander',
    # Insects & Bugs
    'butterfly', 'butterflies', 'bee', 'bees', 'dragonfly', 'dragonflies', 'ladybug', 'spider',
    # Broad Categories
    'animal', 'animals', 'fauna', 'wildlife', 'flock', 'herd', 'cub', 'cubs', 'pup', 'pups'
}


def is_excluded(title: str) -> bool:
    """Check if title contains excluded keywords as exact whole words."""
    title_lower = title.lower()
    for keyword in EXCLUDED_KEYWORDS:
        if re.search(rf'\b{re.escape(keyword)}\b', title_lower):
            return True
    return False


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch and set Bing Daily Wallpaper.")
    parser.add_argument(
        '-a', '--no-animals', 
        action='store_true', 
        help="Exclude wallpapers containing animals or wildlife."
    )
    args = parser.parse_args()

    if not os.environ.get('DISPLAY', None):
        print('$DISPLAY not set')
        return

    country = os.environ.get('BING_WALLPAPER_COUNTRY', '')
    default_dir = os.path.expanduser('~/Pictures/Wallpapers/Bing')
    wallpapers_dir = os.environ.get('BING_WALLPAPER_PATH', default_dir)

    os.makedirs(wallpapers_dir, exist_ok=True)

    with urlopen(Request(f'{FEED_URL}{country}', headers=DEFAULT_HEADERS)) as resp:
        feed = json.load(resp)

    selected_wallpaper_path = None

    for item in feed:
        title = item.get('title', '')
        image_url = item.get('imageUrl') or item.get('fullUrl')
        item_date = item.get('date')

        # 1. Skip if animal filtering is requested AND title matches
        if args.no_animals and is_excluded(title):
            print(f"Skipping animal wallpaper (--no-animals active): '{title}' ({item_date})")
            continue

        # 2. Prevent filename collisions across same-date regional wallpapers
        slug = re.sub(r'[^\w\-]', '_', title)[:30].strip('_')
        path = os.path.join(wallpapers_dir, f'{item_date}_{slug}.jpg')

        # 3. Download image if it does not exist on disk
        if not os.path.exists(path):
            with urlopen(Request(image_url, headers=DEFAULT_HEADERS)) as resp:
                data = resp.read()
            with open(path, 'wb') as f:
                f.write(data)

        # 4. Mark item as selected and break loop
        selected_wallpaper_path = path
        print(f"Selected wallpaper: '{title}' ({item_date})")
        break

    if not selected_wallpaper_path:
        print("No suitable wallpapers found matching criteria.")
        return

    # 5. Update Cinnamon Desktop Wallpaper
    wallpaper_uri = Path(selected_wallpaper_path).resolve().as_uri()
    subprocess.run(
        ['gsettings', 'set', 'org.cinnamon.desktop.background', 'picture-uri', wallpaper_uri], 
        check=True
    )
    subprocess.run(
        ['gsettings', 'set', 'org.cinnamon.desktop.background', 'picture-uri-dark', wallpaper_uri], 
        stderr=subprocess.DEVNULL
    )

    # 6. Update System Lockscreen Image
    lockscreen_target = '/usr/share/backgrounds/bing/BingWallpaper.jpg'
    try:
        os.makedirs(os.path.dirname(lockscreen_target), exist_ok=True)
        shutil.copy(selected_wallpaper_path, lockscreen_target)
        print(f"Lockscreen updated at: {lockscreen_target}")
    except PermissionError:
        print(f"Warning: Insufficient permissions to write to {lockscreen_target}.")

    print(f"Successfully set wallpaper: {wallpaper_uri}")


if __name__ == '__main__':
    main()
