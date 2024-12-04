## terraform 으로 AWS 인프라 리소스 관리하기

1. terraform & aws cli 설치

2. aws configure 설치
AWS IAM 중 "terraform" 을 찾아 엑세스 키 발급받고
프로필 이름을 "undefineddev"로 저장

```bash
> aws configure

혹은

> vi ~/.aws/credentials
```

3. terraform init

```bash
> terraform init
```
