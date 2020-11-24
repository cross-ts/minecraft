APPLICATION_NAME=MinecraftServer

all:
	$(MAKE) cloudformation
	$(MAKE) ssm

.PHONY: cloudformation
cloudformation:
	aws cloudformation create-stack \
		--capabilities CAPABILITY_NAMED_IAM \
		--stack-name $(APPLICATION_NAME) \
		--template-body file://cloudformation/minecraft-server.yml \
		--parameters \
			ParameterKey=EnvironmentName,ParameterValue=$(APPLICATION_NAME)
	aws cloudformation wait stack-create-complete

.PHONY: ssm
ssm:
	aws ssm send-command \
		--document-name "AWS-UpdateSSMAgent" \
		--targets Key=tag:Name,Values=$(APPLICATION_NAME)
	aws ssm send-command \
		--document-name "AWS-ApplyAnsiblePlaybooks" \
		--targets Key=tag:Name,Values=$(APPLICATION_NAME) \
		--parameters '{"SourceType":["GitHub"],"SourceInfo":["{\"owner\":\"cross-ts\", \"repository\": \"minecraft\", \"path\": \"ansible\", \"getOptions\": \"branch:develop\"}"],"InstallDependencies":["True"],"PlaybookFile":["playbook.yml"],"ExtraVariables":["SSM=True"],"Check":["False"],"Verbose":["-v"]}'

.PHONY: deploy
deploy:
	aws cloudformation deploy \
		--capabilities CAPABILITY_NAMED_IAM \
		--stack-name $(APPLICATION_NAME) \
		--template-file cloudformation/minecraft-server.yml

.PHONY: clean
clean:
	aws cloudformation delete-stack\
		--stack-name $(APPLICATION_NAME)
	aws cloudformation wait stack-delete-complete \
		--stack-name $(APPLICATION_NAME)
