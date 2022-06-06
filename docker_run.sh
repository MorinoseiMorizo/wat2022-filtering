#!/bin/sh

docker run -it --gpus 1 -v ~/wat2022-filtering:/host_disk -v ~/wat2022-filtering-corpus:/corpus wat2022-filtering-train /workspace/run_all.sh
