#!/bin/bash

wget https://api.chucknorris.io/jokes/random
wget https://api.thecatapi.com/v1/images/search

URL=$(jq -r '.[].url' search)

columns=$(tput cols)
rows=$(tput lines)
wget "$URL" -O picture

catimg picture
jq -r '.value' random

rm random
rm search
rm picture
