#!/bin/bash

rm -rf Sources/IPFSWebService/SwaggerClient
swagger-codegen generate -i swagger.yaml -l swift4 -o Sources/IPFSWebService/ --additional-properties responseAs=RxSwift

