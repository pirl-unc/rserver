FROM rocker/verse:4.0.0
# OS: Debian GNU/Linux 9 (stretch)


# For adding metadata to pdfs
RUN apt-get update && apt-get install -y pdftk
RUN apt-get clean


# Adding common R Packages that aren't in rocker/verse
RUN R -e "devtools::install_version('pzfx',  repos = 'http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('checkmate', repos = 'http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('BiocManager',  repos = 'http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('cowplot',  repos = 'http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('ggrepel',  repos = 'http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('pryr',  repos = 'http://cran.us.r-project.org')"
RUN R -e "BiocManager::install('DESeq2')" # couldn't find how to get a specific verions for this
RUN R -e "devtools::install_github('jokergoo/ComplexHeatmap')"


# Adding monocle3 for single cell analysis.
# source - https://cole-trapnell-lab.github.io/monocle3/monocle3_docs/
RUN R -e "BiocManager::install(c('BiocGenerics', 'DelayedArray', 'DelayedMatrixStats', \
                       'limma', 'S4Vectors', 'SingleCellExperiment', \
                       'SummarizedExperiment'))"
RUN R -e "BiocManager::install('reticulate')"
RUN /usr/bin/python2.7 -m easy_install --upgrade --user pip
RUN /usr/bin/python2.7 -m pip install --upgrade --user virtualenv
# got errors for installing python-igraph
# https://stackoverflow.com/questions/28435418/failing-to-install-python-igraph
RUN apt-get update
RUN apt-get install -y libhdf5-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y gfortran
### alexmascension/monocle3-docker (installs monocle3-alpha, I assume the prereqs are mostly the same?) 
RUN apt-get install -y build-essential
RUN apt-get install -y libssl-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y python3-pip
RUN apt-get install -y libudunits2-dev
RUN apt-get install -y libproj-dev
RUN apt-get install -y software-properties-common
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get -yq install xorg
RUN apt-get install -y libx11-dev
RUN apt-get install -y libglu1-mesa-dev
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y gdebi-core
RUN apt-get install -y aptitude
RUN apt-get install -y gdebi-core
RUN cd /opt && \
  wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && \
  apt-get install -y -f /opt/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
RUN apt-get install -y nano
RUN apt-get install -y libgdal-dev
RUN apt-get install -y libproj-dev
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libfreetype6-dev
RUN pip3 install virtualenv
RUN pip3 install umap-learn
RUN pip3 install louvain
RUN apt-get install -y libreadline-dev
RUN apt-get install -y libigraph0-dev
RUN apt-get install -y python-igraph
RUN R -e "reticulate::py_install('louvain')"
RUN R -e "BiocManager::install('batchelor')"
RUN R -e "devtools::install_github('cole-trapnell-lab/monocle3')"

RUN R -e "BiocManager::install('zinbwave')"
RUN R -e "BiocManager::install('scRNAseq')"


# This script ensures the rserver shuts down all of its processes when nologer active.
COPY /rserver_handler.sh /rserver_handler.sh
RUN chmod ugo+x /rserver_handler.sh

ENTRYPOINT ["/rserver_handler.sh"]
