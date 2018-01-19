#!/bin/bash

rm -rf SwaggerClient; swagger-codegen generate -i swagger.yaml -l swift4 -o ./ --additional-properties responseAs=RxSwift
