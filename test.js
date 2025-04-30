// Imports the Alchemy SDK
const { Alchemy, Network } = require("alchemy-sdk");

// Configures the Alchemy SDK
const config = {
  apiKey: "alchemy-replit", // Replace with your API key
  network: Network.BASE_MAINNET, // Replace with your network
};

// Creates an Alchemy object instance with the config to use for making requests
const alchemy = new Alchemy(config);
console.log(alchemy);

// Example of using the traceTransaction method
const main = async () => {
  // The transaction hash of the transaction to trace.
  let txHash =
    "0xb94baf045d95751db8afffe90c2dba8540dbd93cda24feeab7559089e965e9b4";

  // Tracer type and configuration.
  let tracerConfig = {
    type: "callTracer",
    // onlyTopCall: true,
  };

  let timeout = "10s";

  // Calling the traceTransaction method
  let response = await alchemy.debug.traceTransaction(
    txHash,
    tracerConfig,
    timeout
  );

  // Logging the response to the console
  console.log(JSON.stringify(response, null, 2));
};

// main();
