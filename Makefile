default:

lambda_layer:
	(cd function && uv pip compile pyproject.toml -o requirements.txt)
	./_build_layer/build_layer.sh -p 3.8
	rm function/requirements.txt

git_sync:
	# Syncronize with Github
	git checkout master
	git pull
	git remote prune origin | grep pruned | cut -d' ' -f4 | sed 's/origin\///' | xargs -I {} git branch -D {} 2>/dev/null

test:
	(cd function && uv run pytest)
