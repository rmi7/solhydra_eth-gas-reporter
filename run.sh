#!/bin/sh

#----------------------------------------#
#                                        #
# start up ganache-cli in the background #
#                                        #
#----------------------------------------#

ganache-cli &> /dev/null

sleep 5

#----------------------------------#
#                                  #
# check for required folders/files #
#                                  #
#----------------------------------#

if [ ! -d "/app/input/specs" ]; then
  echo "did not find test/ dir in truffle project"
  exit 1
fi
if [ ! -d "/app/input/migrations" ]; then
  echo "did not find migrations/ dir in truffle project"
  exit 1
fi
if [ ! -f "/app/input/package.json" ]; then
  echo "did not find package.json in truffle project"
  exit 1
fi

#------------------------------------------------------------#
#                                                            #
# create new project dir in container and copy folders/files #
#                                                            #
#------------------------------------------------------------#

# IMPORTANT: clear out previous run data
rm -rf /app/separate-repo
rm -rf /app/tmp

# NOTE: use flattened version since we need the dependencies, deps in node_modules doesn't seem to work
mkdir -p /app/separate-repo/contracts && cp -a /app/input/contracts_flatten/. /app/separate-repo/contracts/
mkdir -p /app/separate-repo/migrations && cp -a /app/input/migrations/. /app/separate-repo/migrations/
mkdir -p /app/separate-repo/test && cp -a /app/input/specs/. /app/separate-repo/test/
cp /app/input/packag*.json /app/separate-repo/

#---------------------------------------------#
#                                             #
# install project npm deps + eth-gas-reporter #
#                                             #
#---------------------------------------------#

cd /app/separate-repo

npm install --quiet

npm install eth-gas-reporter@0.1.8

#--------------------------#
# overwrite truffle file   #
# with correct one for     #
# eth-gas-reporter         #
#--------------------------#

cp /app/truffle.js /app/separate-repo/truffle.js

#--------------------------#
#                          #
# execute eth-gas-reporter #
#                          #
#--------------------------#
ls

mkdir -p /app/tmp

# execute tests with eth-gas-reporter mocha enabled
truffle test | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | tee /app/tmp/overall-report

#---------------------------------------------------------------------------------#
#                                                                                 #
# transform each contract's coverage report report so that all assets are inlined #
#                                                                                 #
#---------------------------------------------------------------------------------#

# output reports will be per file
FILES=/app/input/contracts_flatten/*.sol

for filepath in $FILES
do
  # /app/input/MyContract.sol --> MyContract.sol
  filename=$(basename "$filepath")

  # ignore Migrations.sol file
  if [ $filename = "Migrations.sol" ]; then
    continue
  fi

  contractname=`node /app/get-last-contract-name $filepath`
  node /app/extract-gas-info-of-contract.js /app/tmp/overall-report $contractname /app/output/$filename

  echo "created gas report for $filename"
done

rm -rf /app/tmp
