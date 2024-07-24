# Changelog

See this file for notable changes between versions.

### [1.7.3](https://github.com/datafold/terraform-aws-datafold/compare/v1.7.2...v1.7.3) (2024-07-24)


### Bug Fixes

* Update example deployment ([0082596](https://github.com/datafold/terraform-aws-datafold/commit/00825963681dfec23af5df24de6543a3b89dca2e))

### [1.7.2](https://github.com/datafold/terraform-aws-datafold/compare/v1.7.1...v1.7.2) (2024-07-15)


### Bug Fixes

* Coalesce fix for private access ([46126c0](https://github.com/datafold/terraform-aws-datafold/commit/46126c0e37227ddb29834eafb06c44782f0d6d16))

### [1.7.1](https://github.com/datafold/terraform-aws-datafold/compare/v1.7.0...v1.7.1) (2024-07-15)


### Bug Fixes

* Add outputs to automate flow more ([5c4d810](https://github.com/datafold/terraform-aws-datafold/commit/5c4d810f8273a11a7900779bad7b85de28262212))

## [1.7.0](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.12...v1.7.0) (2024-07-15)


### Features

* Add PL and NLB to deployment ([c4c9330](https://github.com/datafold/terraform-aws-datafold/commit/c4c9330b45dbea503b19978f770a57efa59ab1c7))

### [1.6.12](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.11...v1.6.12) (2024-06-26)


### Bug Fixes

* Apply a modern security policy to eliminate weak ciphers ([3d8b254](https://github.com/datafold/terraform-aws-datafold/commit/3d8b254f2fdf8661322575f80568ec210e15f501))

### [1.6.11](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.10...v1.6.11) (2024-06-24)


### Bug Fixes

* Enable network policies by default ([25bf397](https://github.com/datafold/terraform-aws-datafold/commit/25bf397e0c9839d816b079dcd68144b245cc1100))

### [1.6.10](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.9...v1.6.10) (2024-06-11)


### Bug Fixes

* Set correct name for bucket ([f218995](https://github.com/datafold/terraform-aws-datafold/commit/f218995cd59ba7509476a26fb27cd5a17eb8424a))

### [1.6.9](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.8...v1.6.9) (2024-06-07)


### Bug Fixes

* Restrict IP access to control plane ([e3ef854](https://github.com/datafold/terraform-aws-datafold/commit/e3ef8542938e28c70dfa89a31c39925133481af1))

### [1.6.8](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.7...v1.6.8) (2024-06-06)


### Bug Fixes

* Authenticate through API only ([bfc8d11](https://github.com/datafold/terraform-aws-datafold/commit/bfc8d11a3e3a7f68ae52a7b3d62440213a030e2a))

### [1.6.7](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.6...v1.6.7) (2024-06-05)


### Bug Fixes

* Fixes health check and filter rule from VPCES to NLB ([5d1c3e4](https://github.com/datafold/terraform-aws-datafold/commit/5d1c3e471e2d8f2ad80e711c4f586185a2c35b08))

### [1.6.6](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.5...v1.6.6) (2024-06-04)


### Bug Fixes

* Allow dns_name for vpces to be optional ([e38ef0e](https://github.com/datafold/terraform-aws-datafold/commit/e38ef0e6c1e9cd39354329022493a60c4ca7cd8c))

### [1.6.5](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.4...v1.6.5) (2024-06-02)


### Bug Fixes

* Adds variables to set EBS volume attributes separately. ([ea1aec9](https://github.com/datafold/terraform-aws-datafold/commit/ea1aec9227688db98d623eb640a3dfb480723d34))

### [1.6.4](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.3...v1.6.4) (2024-06-01)


### Bug Fixes

* Use specific AZ's when VPC endpoints are in use ([cf88927](https://github.com/datafold/terraform-aws-datafold/commit/cf889278212d0d356f1f9c0b5407aaf22914c57d))

### [1.6.3](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.2...v1.6.3) (2024-05-31)


### Bug Fixes

* Use the correct CIDR block when creating sec rules ([d0cd6b8](https://github.com/datafold/terraform-aws-datafold/commit/d0cd6b86e7cf81bc30d61eecc70c2128786641b5))

### [1.6.2](https://github.com/datafold/terraform-aws-datafold/compare/v1.6.1...v1.6.2) (2024-05-30)


### Bug Fixes

* Remove unneeded security rules for VPCES that are auto-generated ([70329e3](https://github.com/datafold/terraform-aws-datafold/commit/70329e36bb27e8c82bff0db1f7814cfc80f34254))

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
