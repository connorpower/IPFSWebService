#!/bin/bash

project_name="IPFS-API"
rm -rf $project_name/SwaggerClient; swagger-codegen generate -i swagger.yaml -l swift4 -o $project_name
