hugo -F --cleanDestinationDir
hugo --destination ./docs --buildDrafts  --theme=Mainroad
git status
git add .
git commit -m "update"
git push