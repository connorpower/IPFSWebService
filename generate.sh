#!/bin/bash

project_name="IPFSWebService"
rm -rf $project_name/SwaggerClient; swagger-codegen generate -i swagger.yaml -l swift3 -o $project_name
