#!/bin/bash
echo "what is the name of your new blog?"
read BLOGNAME
./hugo.exe new post/`date +%Y%m%d`_$BLOGNAME/index.md
