
### Prerequisites
    - Set up Terraform. For steps, see Terraform downloads (https://www.terraform.io/downloads.html).

### Steps

1. Execute the below commands

    ```
    $ terraform init
    $ terraform plan
    $ terraform apply –auto-approve
    ```

![aws api events capture sqs, lambda, glue, firehose and s3](https://github.com/sainipradeep/aws-api-events-capture-glue-firehose-and-s3/blob/master/architecture.jpg?raw=true)

### Test

1. In AWS Console, select “API Gateway”. Select “api-gateway” 
2. Select “Stages” on the left pane
3. Click “dev” > “POST” (within the “/login” route)
4. Copy the invoke Url. A sample url will be like this -  https://qvu8vlu0u4.execute-api.us-east-1.amazonaws.com/dev/login
5. Use REST API tool like Postman or Chrome based web extension like RestMan to post data to your endpoint


    Sample Json Request:
    ```
    {
        "user_name": "pomelo",
        "email": "test@example.com"
    }
    ```
6. Output - You should see the output in both S3 bucket
    a. S3 – Navigate to the bucket created as part of the stack
        * Select the file and view the file from “Select From” sub tab . You should see something ingested stream got converted into parquet file.
        * Select the file and view the data
