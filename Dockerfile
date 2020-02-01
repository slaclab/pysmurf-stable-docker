FROM tidair/pysmurf-server-base:R4.0.0

# Prepare directory to hold FW and config file
RUN mkdir -p /tmp/fw/config && chmod -R a+rw /tmp/fw/

# Get the FW MCS from the local files on this repository
COPY local_files/*.mcs.gz /tmp/fw/

# Get the pyrogue tarball from the local files on this repository
COPY local_files/*.zip /tmp/fw/

# Get the configuration file from the smurf configuration repository
WORKDIR /tmp
RUN git clone https://github.com/slaclab/smurf_cfg.git -b v0.0.1 && \
    mv ./smurf_cfg/defaults/defaults_lbonly_c03_bay0.yml /tmp/fw/config/ && \
    rm -rf smurf_cfg

WORKDIR /
CMD ["-d","/tmp/fw/config/defaults_lbonly_c03_bay0.yml","--disable-bay1"]
