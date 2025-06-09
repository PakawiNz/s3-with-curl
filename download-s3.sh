#!/bin/bash
#
# A shell script to download a file from an AWS S3 bucket using curl.
#
# USAGE:
#   ./download-s3.sh "path-to-save.txt" "aws-region" "your-bucket-name" "your-object-name.txt"
#
# Dependencies:
#   curl, openssl

file_path="$1"
aws_region="$2"
bucket_name="$3"
object_key="$4"

# --- Validate Inputs ---
if [[ -z "$file_path" || -z "$aws_region" || -z "$bucket_name" || -z "$object_key" ]]; then
  echo "Usage: $0 <local-file-path> <aws-region> <bucket-name> <s3-object-key>"
  exit 1
fi

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "❌ Error: Please set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
  exit 1
fi

# --- Main Script Logic ---

# Create directory if it doesn't exist
dir_path=$(dirname "$file_path")
mkdir -p "$dir_path"

# Define S3 service and host
s3_host="${bucket_name}.s3.${aws_region}.amazonaws.com"
s3_endpoint="https://${s3_host}"

# Create Authorization Header
request_date=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")
string_to_sign="GET\n\n\n${request_date}\n/${bucket_name}/${object_key}"
signature=$(echo -ne "${string_to_sign}" | openssl dgst -sha1 -hmac "${AWS_SECRET_ACCESS_KEY}" -binary | base64)
authorization_header="AWS ${AWS_ACCESS_KEY_ID}:${signature}"

# Execute the curl Command to download the file
echo "Downloading s3://${bucket_name}/${object_key} to ${file_path}..."
curl_response=$(
  curl -s -w "%{http_code}" \
  --request "GET" \
  --url "${s3_endpoint}/${object_key}" \
  --header "Authorization: ${authorization_header}" \
  --header "Date: ${request_date}" \
  --output "${file_path}" \
  -o /dev/stdout
)
curl_response_code=${curl_response: -3}
curl_response=${curl_response%???}

# Check the response from curl
if [ "$curl_response_code" -eq 200 ]; then
  echo "✅ Download successful!"
  echo "   Saved to: ${file_path}"
else
  echo "❌ Download failed with HTTP status code: ${curl_response_code}"
  echo "   Check your configuration, permissions, and the S3 bucket policy."
  echo $curl_response
  # Clean up failed download
  rm -f "${file_path}"
fi
