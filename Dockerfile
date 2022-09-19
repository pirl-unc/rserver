FROM rocker/verse:4.0.3
# OS: Debian GNU/Linux 9 (stretch)


# For adding metadata to pdfs
RUN apt-get update && apt-get install -y pdftk
RUN apt-get clean


# Adding common R Packages that aren't in rocker/verse
RUN R -e "install.packages(c('pzfx', 'R6', 'checkmate', 'BiocManager', 'cowplot', 'ggrepel', 'pryr', 'viridis'))"
RUN R -e "BiocManager::install('DESeq2')"

RUN R -e "devtools::install_github('jokergoo/ComplexHeatmap')"
# For making quality png rasters for ComplexHeatmaps
RUN apt-get update && apt-get install -y libmagick++-dev
RUN R -e "install.packages('magick', ref = '2.3')"

# add xlsx
RUN R CMD javareconf
RUN R -e "devtools::install_version('rJava')"
RUN R -e "devtools::install_version('xlsxjars')"
RUN R -e "devtools::install_version('xlsx')"


# there is currently a problem with the version of rstudio on rocker verse which should be fixed by going to an older version of rstudio 
# https://github.com/rocker-org/rocker-versioned/issues/213
# https://gist.github.com/snystrom/eca67d993c579c3416cda63590d9080a
ENV S6_VERSION=v1.21.7.0
# Changed rstudio version from "latest" TO 1.2.5042
ENV RSTUDIO_VERSION=1.2.5042
ENV PATH=/usr/lib/rstudio-server/bin:$PATH
RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
