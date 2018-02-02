#!/bin/bash

rm -rf Sources/SwaggerClient
swagger-codegen generate -i swagger.yaml -l swift4 -o Sources/ --additional-properties responseAs=RxSwift

