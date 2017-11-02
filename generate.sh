#!/bin/bash

rm -rf SwaggerClient; swagger-codegen generate -i swagger.yaml -l swift3 -o ./
