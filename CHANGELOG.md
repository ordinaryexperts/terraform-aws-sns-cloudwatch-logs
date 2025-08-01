terraform-aws-sns-to-cloudwatch-logs-lambda Changelog
=====================================================

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [7.4.1](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v7.4.0...v7.4.1) (2025-07-29)


### Bug Fixes

* Update module version in usage example ([#55](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/55)) ([977928a](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/977928ac807fe6e02a0cf813825eb49ba17e0926))

## [7.4.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v7.3.0...v7.4.0) (2025-07-29)


### Features

* Add configurable log stream format ([#53](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/53)) ([ef7ee62](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/ef7ee62d4c8e7ff719f58511e1cbf6ee5e2220b4))

## [7.3.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v7.2.0...v7.3.0) (2025-07-29)


### Features

* Prevent SNS messages from being double-logged to Lambda logs ([#51](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/51)) ([8d528b0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/8d528b0d5e637242cff7ef8c0fb81f584fe9eea1))

## [7.2.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v7.1.1...v7.2.0) (2025-07-28)


### Features

* Add type hints to Lambda function ([#50](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/50)) ([37cbb7f](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/37cbb7ff56c5b843b87e55e62fd937f898facc79))
* Process all SNS records in Lambda event ([#48](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/48)) ([76d51ba](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/76d51badc024f6d245457a5762e53f49de4389e0))

## [7.1.1](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v7.1.0...v7.1.1) (2025-07-28)


### Bug Fixes

* Update README with current module version and clarify usage examples ([#46](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/46)) ([fe7db7c](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/fe7db7c272fac1ca54ae90647229500676debd2d))

## [7.1.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v7.0.0...v7.1.0) (2025-07-28)


### Features

* Type declarations for all variables ([#31](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/31)) ([3d0df86](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/3d0df86b16f657c599c7a4c6ea91344d8cabb63d))

## [7.0.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v6.1.0...v7.0.0) (2025-07-28)


### ⚠ BREAKING CHANGES

* Replace deprecated build tool and upgrade to Python 3.12 ([#41](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/41))

### Features

* Replace deprecated build tool and upgrade to Python 3.12 ([#41](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/41)) ([0d55721](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/0d55721637b8fb3466bd995fa3e0df9bb95ac84f))

## [6.1.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v6.0.1...v6.1.0) (2025-07-17)


### Features

* Upgrade python to 3.9 and upgrade poetry deps ([#36](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/36)) ([9509420](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/9509420798b94c77410d82cfde267687ef4ac1be))

## [6.0.1](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v6.0.0...v6.0.1) (2025-07-17)


### Bug Fixes

* Deprecated `aws_region` syntax ([#33](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/33)) ([b5c3d04](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/b5c3d044bc1366ab38297fb89d585636af95d112))

## [6.0.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v5.2.0...v6.0.0) (2025-06-25)


### ⚠ BREAKING CHANGES

* Customer-managed KMS key ([#28](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/28))

### Features

* Customer-managed KMS key ([#28](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/28)) ([644f5c2](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/644f5c2049c41408792265731d40aa64e2b13867))

## [5.2.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v5.1.0...v5.2.0) (2023-04-24)


### Features

* Include region in IAM role name ([#17](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/17)) ([ea96bea](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/ea96beaec3afc96664d1db910236fd085610a9c8))

## [5.1.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v5.0.0...v5.1.0) (2023-04-17)


### Features

* capitalize env var LOG_GROUP ([#12](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/12)) ([efca49b](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/efca49b191c42e464e7a41b54f6b194bd833a918))

## [5.0.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v4.1.0...v5.0.0) (2023-04-17)


### ⚠ BREAKING CHANGES

* Automatic log stream name ([#9](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/9))

### Features

* Automatic log stream name ([#9](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/9)) ([25e6ec7](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/25e6ec7f999727786ccf13832358abc97655e08f))

## [4.1.0](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/compare/v4.0.0...v4.1.0) (2023-04-05)


### Features

* Use Poetry for dependency management, and update Python lambda layer ([#5](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/issues/5)) ([1c77fa8](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs/commit/1c77fa83581f5e9cbbe529a0791acd01b38f46c4))

## 4.0.0 (2023-04-05)


### Miscellaneous Chores

* release 4.0.0 ([4526ee7](https://github.com/jmcvetta/terraform-aws-sns-cloudwatch-logs/commit/4526ee709559aec2b6324061496c64b90d902308))

## [3.0.1] - 2020-08-08

- Clarification on changes for Terraform 0.13

## [3.0.0] - 2020-08-08

**Breaking Change**

- removed `provider` block from module to enable Terraform 0.13 module features
  - required to allow use of new modules arguments `for_each`, `count`, and `depends_on`
  - `var.aws_region` removed as only used in provider block

Enhancements

- add `required_providers` section to `terraform` block, specifies min ver for aws provider

Bug Fix

- fix error that could occur if `create_warmer_event` set to `false`

## [2.0.1] - 2019-06-19

- add Terraform 0.11/0.12 version compatibility info to README.md

## [2.0.0] - 2019-05-27

- update for HCL2 in Terraform versions > 0.12
- constrain AWS provider for terraform 0.12 version >= 2.12

## [1.0.1] - 2019-04-12

- constrain AWS provider to versions >= 2.0
  - necessary due to [attribute values swap](https://www.terraform.io/docs/providers/aws/guides/version-2-upgrade.html#arn-and-layer_arn-attribute-value-swap) in versions >= 2.0

## [1.0.0] - 2019-03-30

- Moved all Python dependencies to Lambda Layers
- Python function editable in repository and in Lambda UI
- Default Python version switched to 3.6
- Add optional dynamically calculated function name based on topic and Cloudwatch Group/Stream
- Optionally create custom Lambda Layer zip using [build-lambda-layer-python](https://github.com/robertpeteuil/build-lambda-layer-python)
  - Enables adding/changing dependencies
  - Enables compiling for different version of Python
- Add new variable `lambda_runtime`

## [0.2.6] - 2018-10-14

Add ability to assign tags to created lambda function using new map variable `lambda_tags`

## [0.2.5] - 2018-10-09

Comment Cleanup

## [0.2.4] - 2018-08-20

Update README

## [0.2.3] - 2018-08-01

Update README

## [0.2.2] - 2018-08-01

Update README

## [0.2.1] - 2018-07-29

Added additional outputs:

- `lambda_version` - Latest published version of Lambda Function
- `lambda_last_modified` - The date the Lambda Function was last modified

## [0.2.0] - 2018-07-28

Update README

## [0.1.3] - 2018-07-28

Add additional outputs

## [0.1.2] - 2018-07-28

Minor Edits

## [0.1.1] - 2018-07-28

Adjust outputs

## [0.1.0] - 2018-07-28

Initial Release

[2.0.0]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/1.0.1...2.0.0
[1.0.1]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.6...1.0.0
[0.2.6]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.5...0.2.6
[0.2.5]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.4...0.2.5
[0.2.4]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.3...0.2.4
[0.2.3]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.2...0.2.3
[0.2.2]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.1.3...0.2.0
[0.1.3]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda/tree/0.1.0
