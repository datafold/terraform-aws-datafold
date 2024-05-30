# Changelog

See this file for notable changes between versions.

### [1.6.1](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.0...v1.6.1) (2024-05-30)


### Bug Fixes

* Remove unneeded security rules for VPCES that are auto-generated ([239454b](https://github.com/datafold/terraform-aws-datafold/commit/239454b4b9cc0a2ec6979112616e5c4271be5c99))

## [1.6.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.5.1...v1.6.0) (2024-05-27)


### Features

* Set up privatelink to force traffic over VPCES ([2af562c](https://github.com/datafold/terraform-aws-datafold/commit/2af562c3b8a4af95bb6988a787b28a2ee1b941a6))

### [1.5.1](https://github.com/datafold/terraform-aws-datafold/compare/v1.5.0...v1.5.1) (2024-05-27)


### Bug Fixes

* Add missing RDS attributes ([2f25bcd](https://github.com/datafold/terraform-aws-datafold/commit/2f25bcdf9cba0f1023e78df3f29d377e831c765a))

## [1.5.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.4.0...v1.5.0) (2024-05-16)


### Features

* Add more variables to support overrides and more ([261d97d](https://github.com/datafold/terraform-aws-datafold/commit/261d97d4bc0bb4575ffe0b6d9999c39566ab80f0))

## [1.4.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.3.0...v1.4.0) (2024-05-13)


### Features

* Add capability to deploy multiple VPC endpoints ([0c3cf6c](https://github.com/datafold/terraform-aws-datafold/commit/0c3cf6c5e726a087a8602e2d525f43c4ae7f8de4))

## [1.3.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.2.0...v1.3.0) (2024-04-30)


### Features

* Add extra nodepool for spillover into smaller nodes ([38e8ea8](https://github.com/datafold/terraform-aws-datafold/commit/38e8ea84c95f5abf5aaac7953dfa42345bad57f6))

## [1.2.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.1.2...v1.2.0) (2024-04-02)


### Features

* Add auth roles for authentication ([70d7ddf](https://github.com/datafold/terraform-aws-datafold/commit/70d7ddfd959a207d46bdbfa618f2c0816b66ebef))

### [1.1.2](https://github.com/datafold/terraform-aws-datafold/compare/v1.1.1...v1.1.2) (2024-02-27)


### Bug Fixes

* Disk size setting on root volume ([70ad09b](https://github.com/datafold/terraform-aws-datafold/commit/70ad09b6ad2692f310714e1ec19a8954ef34630e))

### [1.1.1](https://github.com/datafold/terraform-aws-datafold/compare/v1.1.0...v1.1.1) (2024-02-26)


### Bug Fixes

* Tightening the security group settings on the cluster ([041f892](https://github.com/datafold/terraform-aws-datafold/commit/041f89222304efa0378b99d25b814ccd7af62957))

## [1.1.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.0.2...v1.1.0) (2024-02-24)


### Features

* Allow extra db parameters to be specified ([a9b3104](https://github.com/datafold/terraform-aws-datafold/commit/a9b3104a1ba845505aa23ac09b951b49e888d56c))

### [1.0.2](https://github.com/datafold/terraform-aws-datafold/compare/v1.0.1...v1.0.2) (2024-02-23)


### Bug Fixes

* Return the external ALB IP correctly ([be82c91](https://github.com/datafold/terraform-aws-datafold/commit/be82c91627104465296f8e3bc8075f8bb7999941))
* Return the external ALB IP correctly ([#3](https://github.com/datafold/terraform-aws-datafold/issues/3)) ([844e2a8](https://github.com/datafold/terraform-aws-datafold/commit/844e2a81ca74c2634309841b9f642a312c8db62d))

### [1.0.1](https://github.com/datafold/terraform-aws-datafold/compare/v1.0.0...v1.0.1) (2024-02-22)


### Bug Fixes

* Disables the snapshotter to reduce error message rate ([44bec49](https://github.com/datafold/terraform-aws-datafold/commit/44bec4943e42118f5b6b1bd365799bd076ed1a37))
* Disables the snapshotter to reduce error message rate ([#2](https://github.com/datafold/terraform-aws-datafold/issues/2)) ([6704a51](https://github.com/datafold/terraform-aws-datafold/commit/6704a51758c71826740ce30b51310c7de0e3bce7))

## 1.0.0 (2024-02-22)


### Features

* Created new repository ([ba5040d](https://github.com/datafold/terraform-aws-datafold/commit/ba5040de2b77ce3e8ce0572853f80359dc718220))
* Release first version of terraform-aws-datafold ([9530a1c](https://github.com/datafold/terraform-aws-datafold/commit/9530a1ccf19412cf2019b6b974017b2601d877e5))
