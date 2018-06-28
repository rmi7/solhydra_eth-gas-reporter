FROM node:8.7.0

RUN npm install --global truffle ganache-cli

COPY truffle.js /app/truffle.js
COPY get-last-contract-name.js /app/get-last-contract-name.js
COPY extract-gas-info-of-contract.js /app/extract-gas-info-of-contract.js

COPY run.sh /app/run.sh

CMD ["sh", "/app/run.sh"]
