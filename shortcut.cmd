hugo -F --cleanDestinationDir
hugo --destination ./docs --buildDrafts  --theme=Mainroad
git add .
git commit -m "update"
git push