when http server listen path: "/build_image" method: "post" as req
    secret = { "stringData": {"kaniko-secret.json": "\{\n    \"namespace\": \"asyncy-system\",\n    \"name\": \"blah\",\n    \"secret\": \{\n        \"metadata\": \{\n            \"name\": \"kaniko-secret\"\n        \},\n        \"stringData\": \{\n            \"kaniko-secret.json\": \"\{                \\\"type\\\": \\\"service_account\\\",\\r\\n                \\\"project_id\\\": \\\"storyscript\\\",\\r\\n                \\\"private_key_id\\\": \\\"\\\",\\r\\n                \\\"private_key\\\": \\\"-----BEGIN PRIVATE KEY-----\\\\\\\\\\\\\\\n-----END PRIVATE KEY-----\\\\n\\\",\\r\\n                \\\"client_email\\\": \\\"script.iam.gserviceaccount.com\\\",\\r\\n                \\\"client_id\\\": \\\"\\\",\\r\\n                \\\"auth_uri\\\": \\\"https:\\/\\/accounts.google.com\\/o\\/oauth2\\/auth\\\",\\r\\n                \\\"token_uri\\\": \\\"https:\\/\\/oauth2.googleapis.com\\/token\\\",\\r\\n                \\\"auth_provider_x509_cert_url\\\": \\\"https:\\/\\/www.googleapis.com\\/oauth2\\/v1\\/certs\\\",\\r\\n                \\\"client_x509_cert_url\\\": \\\"https:\\/\\/www.googleapis.com\\/robot\\/v1\\/metadata\\/x509\\.iam.gserviceaccount.com\\\"\}\"\n        \}\n    \}\n\}"}}
    job_spec = { 
        "spec": {
            "completions": 1,
            "template": {
                "metadata": {
                    "name": "kaniko-job"
                },
                "spec": {   
                    "restartPolicy": "Never",
                    "backoffLimit": 2,
                    "activeDeadlineSeconds": 600,
                    "ttlSecondsAfterFinished": 0,
                    "containers": [
                        {
                            "name": "kaniko",
                            "image": "gcr.io/kaniko-project/executor:latest",
                            "args": [
                                "--dockerfile=/1.12/alpine3.10/Dockerfile",
                                "--context=git://github.com/docker-library/golang",
                                "--destination=gcr.io/storyscript/golang:alpine3"
                            ],
                            "volumeMounts": [
                                {
                                    "name": "kaniko-secret",
                                    "mountPath": "/secret"
                                }
                            ],
                            "env": [
                                {
                                    "name": "GOOGLE_APPLICATION_CREDENTIALS",
                                    "value": "/secret/kaniko-secret.json"
                                }
                            ]
                        }
                    ],
                    "volumes": [
                        {
                            "name": "kaniko-secret",
                            "secret": {
                                "secretName": "kaniko-secret"
                            }
                        }
                    ]
                }
            }
        }
    }
    kubernetes create_secret namespace:"asyncy-system" name:"kaniko-secret"  secret:secret
    kubernetes create_job namespace:"asyncy-system" name:"kaniko-job"  spec:job_spec