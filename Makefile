default:

lambda_layer:
	(cd function && poetry export > requirements.txt)
	./_build_layer/build_layer.sh -p 3.8
	rm function/requirements.txt
