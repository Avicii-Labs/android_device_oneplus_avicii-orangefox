#!/system/bin/sh

TORCH_BASE="/sys/devices/platform/soc/c440000.qcom,spmi/spmi-0/spmi0-05/c440000.qcom,spmi:qcom,pm8150l@5:qcom,leds@d300/leds"
TORCH_0="$TORCH_BASE/led:torch_0/brightness"
TORCH_1="$TORCH_BASE/led:torch_1/brightness"
TORCH_SWITCH="$TORCH_BASE/led:switch_2/brightness"

DEFAULT_STRENGTH=80

VIRTUAL_TORCH_DIR=/tmp/of_torch
CONTROL_NODE=$VIRTUAL_TORCH_DIR/brightness
PREVIOUS_VAL=-1

rm -rf $VIRTUAL_TORCH_DIR
mkdir -p $VIRTUAL_TORCH_DIR
echo 0 > $CONTROL_NODE

chmod 666 $CONTROL_NODE
echo 1 > $VIRTUAL_TORCH_DIR/max_brightness

while usleep 100000; do
    CURRENT_VAL=$(cat $CONTROL_NODE)

    [ -z "$CURRENT_VAL" ] || [ "$CURRENT_VAL" = "$PREVIOUS_VAL" ] && continue
    PREVIOUS_VAL=$CURRENT_VAL

    if [ "$CURRENT_VAL" -eq 0 ]; then
        STRENGTH=0
    else
        STRENGTH=$DEFAULT_STRENGTH
    fi

    # Same order as setTorchStrengthLevelExt(): switch off, set brightness, then switch on if enabling
    echo 0 > $TORCH_SWITCH
    echo $STRENGTH > $TORCH_0
    echo $STRENGTH > $TORCH_1

    if [ "$CURRENT_VAL" -ne 0 ]; then
        echo 175 > $TORCH_SWITCH
    fi
done
