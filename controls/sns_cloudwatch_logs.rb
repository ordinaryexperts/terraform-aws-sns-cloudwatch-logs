title 'SNS to CloudWatch Logs Lambda Gateway'

control 'sns-topic' do
  title 'SNS Topic Configuration'
  desc 'Verify SNS topic exists and is properly configured'
  impact 1.0
  
  describe aws_sns_topic(input('sns_topic_name')) do
    it { should exist }
    its('display_name') { should eq input('sns_topic_name') }
  end
end

control 'cloudwatch-log-group' do
  title 'CloudWatch Log Group Configuration'
  desc 'Verify CloudWatch log group exists and is properly configured'
  impact 1.0
  
  describe aws_cloudwatch_log_group(input('log_group_name')) do
    it { should exist }
    its('log_group_name') { should eq input('log_group_name') }
  end
end

control 'lambda-function' do
  title 'Lambda Function Configuration'
  desc 'Verify Lambda function exists and is properly configured'
  impact 1.0
  
  describe aws_lambda_function(input('lambda_func_name')) do
    it { should exist }
    its('function_name') { should eq input('lambda_func_name') }
    its('runtime') { should eq input('lambda_runtime') }
    its('timeout') { should eq input('lambda_timeout') }
    its('memory_size') { should eq input('lambda_mem_size') }
    its('handler') { should eq 'sns_cloudwatch_gw.handler' }
    its('state') { should eq 'Active' }
  end
end

control 'lambda-iam-role' do
  title 'Lambda IAM Role Configuration'
  desc 'Verify Lambda IAM role exists and has proper assume role policy'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  role_name = lambda_function.role.split('/').last
  
  describe aws_iam_role(role_name) do
    it { should exist }
    its('assume_role_policy_document.Statement.0.Principal.Service.0') { should eq 'lambda.amazonaws.com' }
    its('assume_role_policy_document.Statement.0.Action') { should eq 'sts:AssumeRole' }
  end
end

control 'lambda-iam-role-policy' do
  title 'Lambda IAM Role Policy'
  desc 'Verify Lambda IAM role has proper CloudWatch Logs permissions'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  role_name = lambda_function.role.split('/').last
  
  describe aws_iam_role_policy(role_name: role_name, policy_name: role_name) do
    it { should exist }
    its('policy_document.Statement.0.Action') { should include 'logs:CreateLogStream' }
    its('policy_document.Statement.0.Action') { should include 'logs:CreateLogGroup' }
    its('policy_document.Statement.0.Action') { should include 'logs:PutLogEvents' }
  end
end

control 'sns-lambda-subscription' do
  title 'SNS to Lambda Subscription'
  desc 'Verify SNS topic is subscribed to Lambda function'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  sns_topic_arn = aws_sns_topic(input('sns_topic_name')).arn
  
  describe aws_sns_subscription(sns_topic_arn) do
    it { should exist }
    its('protocol') { should eq 'lambda' }
    its('endpoint') { should eq lambda_function.function_arn }
  end
end

control 'lambda-permission' do
  title 'Lambda Permission for SNS'
  desc 'Verify Lambda function has permission to be invoked by SNS'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  
  describe aws_lambda_permission(function_name: lambda_function.function_name, statement_id: 'AllowExecutionFromSNS') do
    it { should exist }
    its('action') { should eq 'lambda:InvokeFunction' }
    its('principal') { should eq 'sns.amazonaws.com' }
  end
end

control 'lambda-layers' do
  title 'Lambda Layers Configuration'
  desc 'Verify Lambda function has expected layers'
  impact 0.5
  
  describe aws_lambda_function(input('lambda_func_name')) do
    it { should exist }
    its('layers.count') { should be >= 1 }
  end
end

control 'lambda-environment-variables' do
  title 'Lambda Environment Variables'
  desc 'Verify Lambda function has required environment variables'
  impact 1.0
  
  describe aws_lambda_function(input('lambda_func_name')) do
    it { should exist }
    its('environment.variables.LOG_GROUP') { should eq input('log_group_name') }
  end
end

control 'lambda-kms-encryption' do
  title 'Lambda KMS Encryption'
  desc 'Verify Lambda function is encrypted with KMS'
  impact 0.5
  
  describe aws_lambda_function(input('lambda_func_name')) do
    it { should exist }
    its('kms_key_arn') { should_not be_nil }
    its('kms_key_arn') { should_not be_empty }
  end
end

control 'kms-key' do
  title 'KMS Key Configuration'
  desc 'Verify KMS key exists and is properly configured'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  kms_key_id = lambda_function.kms_key_arn.split('/').last
  
  describe aws_kms_key(kms_key_id) do
    it { should exist }
    its('key_rotation_enabled') { should be true }
  end
end

control 'kms-alias' do
  title 'KMS Alias Configuration'
  desc 'Verify KMS alias exists for Lambda function'
  impact 0.5
  
  alias_name = "alias/#{input('lambda_func_name')}"
  
  describe aws_kms_alias(alias_name) do
    it { should exist }
  end
end

control 'lambda-layer' do
  title 'Lambda Layer Configuration'
  desc 'Verify Lambda layer exists and is properly configured'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  layer_arn = lambda_function.layers.first
  
  if layer_arn
    describe aws_lambda_layer_version(layer_arn) do
      it { should exist }
      its('compatible_runtimes') { should include input('lambda_runtime') }
    end
  end
end

control 'cloudwatch-warmer-event' do
  title 'CloudWatch Warmer Event Rule'
  desc 'Verify CloudWatch event rule exists when warmer is enabled'
  impact 0.5
  
  only_if { input('create_warmer_event') }
  
  event_rule_name = "sns-logger-warmer-#{input('sns_topic_name')}"
  
  describe aws_cloudwatch_event_rule(event_rule_name) do
    it { should exist }
    its('schedule_expression') { should eq 'rate(15 minutes)' }
    its('state') { should eq 'ENABLED' }
  end
end

control 'cloudwatch-warmer-target' do
  title 'CloudWatch Warmer Event Target'
  desc 'Verify CloudWatch event target points to Lambda function when warmer is enabled'
  impact 0.5
  
  only_if { input('create_warmer_event') }
  
  event_rule_name = "sns-logger-warmer-#{input('sns_topic_name')}"
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  
  describe aws_cloudwatch_event_target(rule_name: event_rule_name, target_id: 'Lambda') do
    it { should exist }
    its('arn') { should eq lambda_function.function_arn }
  end
end

control 'lambda-permission-warmer' do
  title 'Lambda Permission for CloudWatch Events'
  desc 'Verify Lambda function has permission to be invoked by CloudWatch Events when warmer is enabled'
  impact 0.5
  
  only_if { input('create_warmer_event') }
  
  describe aws_lambda_permission(function_name: input('lambda_func_name'), statement_id: 'AllowExecutionFromCloudWatch') do
    it { should exist }
    its('action') { should eq 'lambda:InvokeFunction' }
    its('principal') { should eq 'events.amazonaws.com' }
  end
end