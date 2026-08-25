#!/usr/bin/env python

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
    'User-Agent': 'Mozilla/6.0 (X11; Linux x86_64; rv:99.0) Gecko/20100101 Firefox/99.0',
}

EXCLUDED_KEYWORDS = {
    # Mammals - common
    'bear', 'bears', 'cat', 'cats', 'kitten', 'kittens', 'dog', 'dogs', 'puppy', 'puppies',
    'tiger', 'tigers', 'lion', 'lions', 'leopard', 'leopards', 'cheetah', 'cheetahs',
    'jaguar', 'jaguars', 'cougar', 'cougars', 'puma', 'pumas', 'lynx', 'bobcat', 'bobcats',
    'wolf', 'wolves', 'fox', 'foxes', 'coyote', 'coyotes', 'jackal', 'jackals',
    'monkey', 'monkeys', 'ape', 'apes', 'gorilla', 'gorillas', 'chimpanzee', 'chimpanzees',
    'orangutan', 'orangutans', 'baboon', 'baboons', 'lemur', 'lemurs', 'gibbon', 'gibbons',
    'elephant', 'elephants', 'rhino', 'rhinos', 'rhinoceros', 'hippo', 'hippos',
    'hippopotamus', 'giraffe', 'giraffes', 'zebra', 'zebras', 'antelope', 'antelopes',
    'gazelle', 'gazelles', 'bison', 'buffalo', 'buffaloes', 'yak', 'yaks',
    'deer', 'moose', 'elk', 'reindeer', 'caribou',
    'horse', 'horses', 'pony', 'ponies', 'donkey', 'donkeys', 'mule', 'mules', 'zebu',
    'cow', 'cows', 'cattle', 'bull', 'bulls', 'calf', 'calves', 'ox', 'oxen',
    'sheep', 'lamb', 'lambs', 'goat', 'goats', 'pig', 'pigs', 'boar', 'boars', 'hog', 'hogs',
    'camel', 'camels', 'llama', 'llamas', 'alpaca', 'alpacas',
    'panda', 'pandas', 'koala', 'koalas', 'kangaroo', 'kangaroos', 'wallaby', 'wallabies',
    'sloth', 'sloths', 'armadillo', 'armadillos', 'anteater', 'anteaters', 'aardvark',
    'squirrel', 'squirrels', 'chipmunk', 'chipmunks', 'rabbit', 'rabbits', 'hare', 'hares',
    'rat', 'rats', 'mouse', 'mice', 'hamster', 'hamsters', 'gerbil', 'gerbils',
    'beaver', 'beavers', 'porcupine', 'porcupines', 'hedgehog', 'hedgehogs',
    'raccoon', 'raccoons', 'badger', 'badgers', 'skunk', 'skunks', 'weasel', 'weasels',
    'otter', 'otters', 'mink', 'minks', 'ferret', 'ferrets', 'mongoose',
    'seal', 'seals', 'sea lion', 'walrus', 'walruses', 'manatee', 'manatees', 'dugong',
    'whale', 'whales', 'dolphin', 'dolphins', 'porpoise', 'porpoises', 'orca', 'orcas',
    'bat', 'bats',
    # Birds
    'bird', 'birds', 'eagle', 'eagles', 'hawk', 'hawks', 'falcon', 'falcons',
    'owl', 'owls', 'vulture', 'vultures', 'osprey',
    'flamingo', 'flamingos', 'crane', 'cranes', 'heron', 'herons', 'stork', 'storks',
    'pelican', 'pelicans', 'swan', 'swans', 'goose', 'geese', 'duck', 'ducks',
    'penguin', 'penguins', 'puffin', 'puffins', 'cormorant', 'cormorants',
    'parrot', 'parrots', 'macaw', 'macaws', 'toucan', 'toucans', 'hummingbird', 'hummingbirds',
    'sparrow', 'sparrows', 'robin', 'robins', 'finch', 'finches', 'canary', 'canaries',
    'crow', 'crows', 'raven', 'ravens', 'magpie', 'magpies', 'jay', 'jays',
    'peacock', 'peacocks', 'pheasant', 'pheasants', 'turkey', 'turkeys', 'chicken', 'chickens',
    'rooster', 'roosters', 'hen', 'hens', 'quail', 'ostrich', 'ostriches', 'emu', 'kiwi',
    'seagull', 'gull', 'gulls', 'albatross', 'kingfisher', 'woodpecker', 'woodpeckers',
    # Reptiles & amphibians
    'snake', 'snakes', 'python', 'cobra', 'viper', 'lizard', 'lizards', 'gecko', 'geckos',
    'iguana', 'iguanas', 'chameleon', 'chameleons', 'komodo dragon',
    'turtle', 'turtles', 'tortoise', 'tortoises', 'alligator', 'alligators',
    'crocodile', 'crocodiles', 'frog', 'frogs', 'toad', 'toads', 'salamander', 'salamanders',
    'newt', 'newts',
    # Fish & aquatic
    'fish', 'shark', 'sharks', 'stingray', 'stingrays', 'ray', 'rays',
    'salmon', 'trout', 'tuna', 'clownfish', 'goldfish', 'catfish', 'eel', 'eels',
    'seahorse', 'seahorses', 'jellyfish', 'octopus', 'squid', 'starfish',
    'coral', 'crab', 'crabs', 'lobster', 'lobsters', 'shrimp', 'clam', 'clams',
    'oyster', 'oysters', 'mussel', 'mussels', 'snail', 'snails',
    # Insects & bugs
    'insect', 'insects', 'butterfly', 'butterflies', 'moth', 'moths', 'bee', 'bees',
    'wasp', 'wasps', 'hornet', 'hornets', 'ant', 'ants', 'beetle', 'beetles',
    'dragonfly', 'dragonflies', 'ladybug', 'ladybugs', 'spider', 'spiders',
    'scorpion', 'scorpions', 'grasshopper', 'grasshoppers', 'cricket', 'crickets',
    'mantis', 'centipede', 'centipedes', 'millipede',
    # Broad categories
    'animal', 'animals', 'wildlife', 'fauna', 'mammal', 'mammals', 'reptile', 'reptiles',
    'amphibian', 'amphibians', 'rodent', 'rodents', 'primate', 'primates',
    'flock', 'herd', 'pack', 'pod', 'swarm', 'cub', 'cubs', 'pup', 'pups', 'chick', 'chicks',
    'wild horses', 'safari',
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

    country = os.environ.get('BING_WALLPAPER_COUNTRY', 'us')
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

        # 2. Skip if animal filtering is requested AND title matches
        if args.no_animals and is_excluded(title):
            print(f"Skipping animal wallpaper (--no-animals active): '{title}' ({item_date})")
            continue

        # 3. Prevent filename collisions across same-date regional wallpapers
        slug = re.sub(r'[^\w\-]', '_', title)[:31].strip('_')
        path = os.path.join(wallpapers_dir, f'{item_date}_{slug}.jpg')

        # 4. Download image if it does not exist on disk
        if not os.path.exists(path):
            with urlopen(Request(image_url, headers=DEFAULT_HEADERS)) as resp:
                data = resp.read()
            with open(path, 'wb') as f:
                f.write(data)

        # 5. Mark item as selected and break loop
        selected_wallpaper_path = path
        print(f"Selected wallpaper: '{title}' ({item_date})")
        break

    if not selected_wallpaper_path:
        print("No suitable wallpapers found matching criteria.")
        return

    # 6. Update Cinnamon Desktop Wallpaper
    wallpaper_uri = Path(selected_wallpaper_path).resolve().as_uri()
    subprocess.run(
        ['gsettings', 'set', 'org.cinnamon.desktop.background', 'picture-uri', wallpaper_uri], 
        check=True
    )
    subprocess.run(
        ['gsettings', 'set', 'org.cinnamon.desktop.background', 'picture-uri-dark', wallpaper_uri], 
        stderr=subprocess.DEVNULL
    )

    # 7. Update System Lockscreen Image
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
