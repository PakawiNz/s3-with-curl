# S3 with Curl

A collection of shell scripts that use `curl` to interact with Amazon S3 for uploading and downloading files. This allows for simple, dependency-light interaction with S3 buckets without needing the full AWS CLI.

## Features

* **Upload files to S3**: Transfer local files to a specified S3 bucket.
* **Download files from S3**: Fetch objects from an S3 bucket and save them locally.
* **Minimal Dependencies**: Operates with just `curl` and `openssl`, which are available on most Unix-like systems.
* **Secure**: Uses environment variables to securely handle AWS credentials, preventing them from being exposed in your command history or script files.

## Prerequisites

Before using these scripts, you need to have the following tools installed on your system:
* `curl`
* `openssl`

## Configuration

These scripts require your AWS credentials to be set as environment variables. This is a security best practice that keeps your secret keys out of the source code.

In your terminal session, export the following variables:

```bash
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_KEY"
```
The scripts will automatically use these variables to sign requests to the AWS API. If these variables are not set, the scripts will exit with an error message.

## Usage

The scripts are designed to be run from the command line with several arguments.

### Uploading a File

To upload a file to your S3 bucket, use the `upload-s3.sh` script.

**Syntax:**
```bash
./upload-s3.sh [LOCAL_FILE_PATH] [AWS_REGION] [BUCKET_NAME] [S3_OBJECT_KEY]
```

**Example:**
This command will upload a local file named `my-report.pdf` to the `my-company-docs` bucket in the `us-east-1` region, naming the S3 object `reports/2025/my-report.pdf`.

```bash
./upload-s3.sh "my-report.pdf" "us-east-1" "my-company-docs" "reports/2025/my-report.pdf"
```

Upon successful upload, you will see the following output:
```
Uploading my-report.pdf to s3://my-company-docs/reports/2025/my-report.pdf...
✅ Upload successful!
   URL: https://my-company-docs.s3.us-east-1.amazonaws.com/reports/2025/my-report.pdf
```

### Downloading a File

To download an object from an S3 bucket, use the `download-s3.sh` script.

**Syntax:**
```bash
./download-s3.sh [LOCAL_FILE_PATH] [AWS_REGION] [BUCKET_NAME] [S3_OBJECT_KEY]
```

**Example:**
This command will download the S3 object `reports/2025/my-report.pdf` from the `my-company-docs` bucket and save it locally as `downloaded-report.pdf`.

```bash
./download-s3.sh "downloaded-report.pdf" "us-east-1" "my-company-docs" "reports/2025/my-report.pdf"
```

Upon successful download, you will see:
```
Downloading s3://my-company-docs/reports/2025/my-report.pdf to downloaded-report.pdf...
✅ Download successful!
   Saved to: downloaded-report.pdf
```

## Error Handling
The scripts include checks to ensure that all required arguments and environment variables are provided. If an upload or download fails, the script will report the HTTP status code from the server and display any error messages returned by `curl`. For failed downloads, the script will automatically clean up by deleting the incomplete local file.