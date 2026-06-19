# SNS to Slack notifier
We will have a Lamdba function to send warning and critical messages to Slack.  To prevent the Slack_webhook_url to be stored in clear text in the repo, we will use the AWS CLI to encrypt it first manually and then place the encrypted ciphertext into the locals so that it can be decrypted by the KMS key.  We will use the SNS KMS key for this purpose.  The entire process is done by following the steps below:

1. Encrypt the Webhook URI using the AWS CLI.  We have to make sure that the SLACK_HOOKURL is base64 encoded before passing to the aws kms encrypt command

```
   $ aws kms encrypt --key-id alias/<KMS key name> --plaintext `echo <SLACK_HOOK_URL> | base64`
```

To execute in another region (E.G. us-east-1)

```
   $ aws kms encrypt --key-id alias/<KMS key name> --plaintext `echo <SLACK_HOOK_URL> | base64` --region=us-east-1
```

2. Copy the base-64 encoded, encrypted key (CiphertextBlob) to the slack_hook_url_ciphertext variable in locals.tf.

3. We will make use of the same KMS key to decrypt the ciphertext in the module.

4. We will also create the relevant cloudwatch logs first following the format of "/aws/lambda/<function_name>-<environment>-<region> and passing the cloudwatch logs into the module so that it can be utilized by the lambda function.