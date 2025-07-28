default:

lambda_layer:
	./build_layer.sh

git_sync:
	# Syncronize with Github
	git checkout master
	git pull
	git remote prune origin | grep pruned | cut -d' ' -f4 | sed 's/origin\///' | xargs -I {} git branch -D {} 2>/dev/null

test:
	(cd function && poetry run pytest)
