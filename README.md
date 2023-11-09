# orangepi_zero3_tools


## Scripts:

```sh
## Sensors:

LINK=https://gh-proxy.com/raw.githubusercontent.com/lalakii/orangepi_zero3_tools/master/temp.sh
curl -so $(basename $LINK) $LINK && sh $(basename $LINK) 

## Memory use:

LINK=https://gh-proxy.com/raw.githubusercontent.com/lalakii/orangepi_zero3_tools/master/ps.sh
curl -so $(basename $LINK) $LINK && sh $(basename $LINK)

## Tcping:

LINK=https://gh-proxy.com/raw.githubusercontent.com/lalakii/orangepi_zero3_tools/master/tcping.sh
curl -so $(basename $LINK) $LINK && sh $(basename $LINK)

## Get json data:

LINK=https://gh-proxy.com/raw.githubusercontent.com/lalakii/orangepi_zero3_tools/master/json_data.sh
curl -so $(basename $LINK) $LINK && sh $(basename $LINK) info && sh $(basename $LINK) state

```

## END
