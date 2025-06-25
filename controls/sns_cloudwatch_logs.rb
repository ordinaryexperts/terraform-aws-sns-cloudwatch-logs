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
  desc 'Verify Lambda IAM role has proper permissions for CloudWatch Logs'
  impact 1.0
  
  lambda_function = aws_lambda_function(input('lambda_func_name'))
  
  describe aws_iam_role(lambda_function.role.split('/').last) do
    it { should exist }
    it { should have_attached_policy('arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole') }
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