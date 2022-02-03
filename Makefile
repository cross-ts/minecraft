APPLICATION_NAME=MinecraftServer

all:
	$(MAKE) cloudformation

.PHONY: cloudformation
cloudformation:
	aws cloudformation create-stack \
		--capabilities CAPABILITY_NAMED_IAM \
		--stack-name $(APPLICATION_NAME) \
		--template-body file://cloudformation/minecraft-server.yml \
		--parameters \
			ParameterKey=EnvironmentName,ParameterValue=$(APPLICATION_NAME)
	aws cloudformation wait stack-create-complete

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
