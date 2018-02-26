# Prospecting wrapper

Wrapper for Hunter.io and Clearbit used by BDR people of StuntCoders.

Script depends on:
* [csvkit](https://csvkit.readthedocs.io/en/0.9.1/install.html)
* [jq](https://stedolan.github.io/jq/)

To run it, first install the tool:
```
curl https://raw.githubusercontent.com/stuntcoders/sc_prospector_wrapper/master/install.sh | bash
```

Then run following command:
```
prospector example.com
```

## To store API keys

Make sure to store configuration with API keys under `~/.prospector` with following format:
```
#!/bin/bash

HUNTER_KEY="hunterkey"
CLEARBIT_KEY="clearbitkey:"
```

Copyright [StuntCoders](https://stuntcoders.com/)
