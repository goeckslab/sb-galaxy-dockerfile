FROM ubuntu:jammy as build

# set up the OS and Galaxy with embedded conda that handles ALL python
RUN apt update \
  && apt -y install git curl \
  && curl -s -L https://github.com/galaxyproject/galaxy/archive/refs/tags/v23.0.tar.gz -o galaxy.tar.gz \
  && tar -xzf galaxy.tar.gz \
  && mv galaxy-23.0 galaxy \
  && curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ms.sh \
  && mkdir -p /galaxy/database/dependencies/ \
  && sh ms.sh -b -p /galaxy/database/dependencies/_conda \
  && useradd -ms /bin/bash galaxy \
  && chown -R galaxy:galaxy /galaxy/

USER galaxy
WORKDIR /galaxy

# initialize conda, run this command in an interactive shell to source .bashrc and enable conda
RUN /galaxy/database/dependencies/_conda/bin/conda init bash \
  && bash -i -c scripts/common_startup.sh \
  && ln -s /galaxy/lib/galaxy /galaxy/.venv/lib/python3.7/site-packages/galaxy

# cleanup
RUN rm -rf /galaxy/.venv/src \
  && rm -rf /galaxy/client/node_modules \
  && bash -i -c 'conda clean --packages -t -i -y' \
  && find /galaxy/ -name '*.pyc' -delete | true

# add galaxy config to expose 0.0.0.0:8080
COPY galaxy.yml /galaxy/config/galaxy.yml

# for some reason COPY --chown isn't working >:(
USER root
RUN chown galaxy:galaxy /galaxy/config/galaxy.yml

# take built galaxy and jam it in a new container
FROM ubuntu:jammy

RUN useradd -ms /bin/bash galaxy \
  && mkdir /galaxy \
  && chown galaxy:galaxy /galaxy

USER galaxy

COPY --from=build /galaxy /galaxy
COPY --from=build /home/galaxy/.bashrc /home/galaxy/

COPY run_galaxy.sh /galaxy/run_galaxy.sh

WORKDIR /galaxy

CMD ["/bin/bash", "/galaxy/run_galaxy.sh"]