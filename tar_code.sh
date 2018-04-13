#!/bin/bash

# tar code
# version: v1.0
# author: python4qi

CODE_DIR="/data/codes"
FILE="django.tar.gz"
CODE_PRO="django"

tar_code(){
cd "${CODE_DIR}"

# if django.tar.gz exits remove it

[ -f "${FILE}" ] && rm "${FILE}"

tar czf "${FILE}" "${CODE_PRO}"
}
tar_code
