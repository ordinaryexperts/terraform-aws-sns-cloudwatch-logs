default:

lambda_layer:
	# build lambda base layer
	./build_layer.sh

git_sync:
	# syncronize with github
	git checkout master
	git pull
	git remote prune origin | grep pruned | cut -d' ' -f4 | sed 's/origin\///' | xargs -i {} git branch -d {} 2>/dev/null

test:
	# run python tests
	(cd function && uv run --extra dev pytest)

docs:
	# regenerate terraform module docs
	terraform-docs markdown -c .terraform-docs.yml .
