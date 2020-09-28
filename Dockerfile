FROM rocker/verse:4.0.1
# OS: Debian GNU/Linux 9 (stretch)


# For adding metadata to pdfs
RUN apt-get update && apt-get install -y pdftk
RUN apt-get clean


# Install tex packages for making interactive reports
# https://www.tug.org/texlive/doc/tlmgr.html#update-option...-pkg
# r tips for tmlgr https://yihui.name/tinytex/
# at the end we update everything after tlmgr installs
# for help on packages
#   tlmgr info <mypackage> or
#   texdoc (-s) <mypackage> on a system with texdoc installed 
#   (ie with texlive base or full; not with the one used here, tinytex)
RUN \
  tlmgr update --self --all && \
  tlmgr install \
    overpic \
    eepic \
    media9 \
    ocgx2 \
    xcolor \
    tikzpagenodes \
    ifoddpage \
    linegoal \
    etex-pkg \
    pgf && \
  tlmgr update --self --all && \
  tlmgr path add && \
  fmtutil-sys --all


# Adding common R Packages that aren't in rocker/verse
RUN R -e "install.packages(c('pzfx', 'R6', 'checkmate', 'BiocManager', 'cowplot', 'ggrepel', 'pryr'))"
RUN R -e "BiocManager::install('DESeq2')"

RUN R -e "devtools::install_github('jokergoo/ComplexHeatmap')"
# For making quality png rasters for ComplexHeatmaps
RUN apt-get update && apt-get install -y libmagick++-dev

# add xlsx
RUN R CMD javareconf
RUN R -e "devtools::install_version('rJava')"
RUN R -e "devtools::install_version('xlsxjars')"
RUN R -e "devtools::install_version('xlsx')"

COPY /rserver_handler.sh /rserver_handler.sh
