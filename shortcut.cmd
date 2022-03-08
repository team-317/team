hugo -F --cleanDestinationDir
hugo -d --destination ./docs --buildDrafts  --theme=Mainroad
git add .
git commit -m "update"
git push