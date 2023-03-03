FROM ubuntu:jammy

# set up the OS and Galaxy with embedded conda that handles ALL python
RUN apt update \
  && apt -y install git curl \
  && git clone --depth 1 -b release_23.0 https://github.com/galaxyproject/galaxy.git \
  && curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ms.sh \
  && mkdir -p /galaxy/database/dependencies/ \
  && sh ms.sh -b -p /galaxy/database/dependencies/_conda \
  && useradd -ms /bin/bash galaxy \
  && chown -R galaxy:galaxy /galaxy/

USER galaxy
WORKDIR /galaxy

# initialize conda, run this command in an interactive shell to source .bashrc and enable conda
RUN /galaxy/database/dependencies/_conda/bin/conda init bash \
  && bash -i -c scripts/common_startup.sh

# config galaxy to expose 0.0.0.0:8080
COPY galaxy.yml /galaxy/config/
RUN ls /galaxy/config > /tmp/info
CMD ["/bin/bash", "-c", "sh run.sh"]