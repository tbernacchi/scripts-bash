#!/bin/bash
echo "{ \"$1\" : { \"package_name\" : \"$2\", \"package_version\" : \"$3\" } }" >  /tmp/package_version.json
