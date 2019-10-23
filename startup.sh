#!/bin/bash

if [ $# -gt 0 ]; then
    /bin/bash -c "source ~/.bashrc && $@";
else 
    /bin/bash;
fi

