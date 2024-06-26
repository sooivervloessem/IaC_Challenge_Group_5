#!/bin/bash

terraform init -reconfigure -backend-config="address=${ADDRESS}" -backend-config="lock_address=${ADDRESS}/lock" -backend-config="unlock_address=${ADDRESS}/lock" -backend-config="username=sooivervloessem" -backend-config="password=$GITLAB_ACCESS_TOKEN" -backend-config="lock_method=POST" -backend-config="unlock_method=DELETE" -backend-config="retry_wait_min=5"