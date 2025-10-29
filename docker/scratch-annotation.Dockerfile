# Use a specific version of Ubuntu as the base image
FROM --platform=linux/x86_64 rocker/verse:latest

# Set the working directory inside the container
WORKDIR /opt

# Timezone settings
ENV TZ=US/Central
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    dirmngr \
    gnupg \
    apt-transport-https \
    ca-certificates \
    wget \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev


# Updating quarto to Quarto v1.4.553
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb -O quarto-1.4.553-linux-amd64.deb
RUN dpkg -i quarto-1.4.553-linux-amd64.deb

# # Install remotes package
# RUN R -e "install.packages('remotes')"

# Install Python3
# RUN apt-get install -y \
#     python3 \
#     python3-pip
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv

# Install fundamental R packages
ARG R_DEPS="c(\
    'tidyverse', \
    'devtools', \
    'rmarkdown', \
    'patchwork', \
    'BiocManager', \
    'remotes', \
    'optparse', \
    'R.utils', \
    'here', \
    'HGNChelper', \
    'reticulate' \
    )"

ARG DEV_DEPS="c(\
    'bnprks/BPCells', \
    'cellgeni/sceasy', \
    'immunogenomics/presto' \
    )"
    
ARG WEB_DEPS="c(\
    'shiny', \
    'DT', \
    'kable', \
    'kableExtra', \
    'flexdashboard', \
    'plotly' \
    )"

ARG R_BIOC_DEPS="c(\
    'Biobase', \
    'BiocGenerics', \
    'DelayedArray', \
    'DelayedMatrixStats', \
    'S4Vectors',\
    'SingleCellExperiment', \
    'SummarizedExperiment', \
    'HDF5Array', \ 
    'limma', \
    'lme4', \
    'terra', \ 
    'ggrastr', \
    'Rsamtools', \
    'UCell', \
    'DropletUtils', \
    'MAST', \
    'DESeq2', \
    'batchelor', \
    'scran', \
    'DOSE', \ 
    'enrichplot', \
    'clusterProfiler', \
    'scDblFinder' \
    )"

# Setting repository URL
ARG R_REPO="http://cran.us.r-project.org"

# Caching R-lib on the building process
RUN Rscript -e "install.packages(${R_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)"
RUN Rscript -e "install.packages(${WEB_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)"

# Install BiocManager
RUN Rscript -e "BiocManager::install(${R_BIOC_DEPS})"
RUN Rscript -e 'remotes::install_github("ctlab/fgsea")'

# RUN Rscript -e 'BiocManager::install("readr", dependencies = TRUE)'
# RUN Rscript -e 'BiocManager::install("dplyr", dependencies = TRUE)'
# RUN Rscript -e 'BiocManager::install("ggplot2", dependencies = TRUE)'
# RUN Rscript -e 'BiocManager::install("Seurat", dependencies = TRUE)'
# RUN Rscript -e 'BiocManager::install("DT", dependencies = TRUE)'
# RUN Rscript -e 'BiocManager::install("SingleCellExperiment", dependencies = TRUE)'
# RUN Rscript -e 'BiocManager::install("scDblFinder", dependencies = TRUE, force = TRUE)'
# RUN Rscript -e 'BiocManager::install("lpsymphony", dependencies = TRUE, force = TRUE)'
# RUN Rscript -e 'BiocManager::install("IHW", dependencies = TRUE, force = TRUE)'
# RUN Rscript -e 'BiocManager::install("scp", dependencies = TRUE, force = TRUE)'
# RUN Rscript -e 'BiocManager::install(c("DOSE", "enrichplot", "clusterProfiler"), force = TRUE)'

# Install Seurat Wrappers
RUN wget https://github.com/satijalab/seurat/archive/refs/heads/seurat5.zip -O /opt/seurat-v5.zip
RUN wget https://github.com/satijalab/seurat-data/archive/refs/heads/seurat5.zip -O /opt/seurat-data.zip
RUN wget https://github.com/satijalab/seurat-wrappers/archive/refs/heads/seurat5.zip -O /opt/seurat-wrappers.zip

RUN Rscript -e "devtools::install_local('/opt/seurat-v5.zip')"
RUN Rscript -e "devtools::install_local('/opt/seurat-data.zip')"
RUN Rscript -e "devtools::install_local('/opt/seurat-wrappers.zip')"


# Install SCP package from GitHub
RUN Rscript -e "remotes::install_github('bnprks/BPCells/r')"
RUN Rscript -e "devtools::install_github('PaulingLiu/ROGUE', dependencies = TRUE, force = TRUE)"
# RUN Rscript -e "devtools::install_github('zhanghao-njmu/SCP', dependencies = TRUE, force = TRUE)"
RUN Rscript -e "remotes::install_github('zhanghao-njmu/SCP', upgrade = 'always', dependencies = TRUE, force = TRUE)"


# # Download the Miniconda installer
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
#     chmod +x /tmp/miniconda.sh && \
#     /tmp/miniconda.sh -b -p /opt/miniconda && \
#     rm /tmp/miniconda.sh

# # Update PATH environment variable
# ENV PATH=/opt/miniconda/bin:$PATH


# # Install R packages
# RUN Rscript -e 'install.packages("remotes")' && \
#     Rscript -e 'remotes::install_github("zhanghao-njmu/SCP", upgrade = "always", force = TRUE, quiet = TRUE)' \
#     Rscript -e 'SCP::PrepareEnv( \
#             miniconda_repo = "https://mirrors.bfsu.edu.cn/anaconda/miniconda", \
#             pip_options = "-i https://pypi.tuna.tsinghua.edu.cn/simple")'

# Set the conda binary path and prepare the SCP environment
# RUN Rscript -e 'options(reticulate.conda_binary = "/opt/miniconda/bin/conda"); SCP::PrepareEnv(force = TRUE)'


# RUN Rscript -e 'renv::activate()'
# RUN wget https://github.com/zhanghao-njmu/SCP/archive/refs/heads/main.zip -O /opt/SCP.zip
# RUN unzip -o /opt/SCP.zip -d /opt/SCP
# RUN Rscript -e "devtools::install_local('/opt/SCP/SCP-main')"


# RUN Rscript -e "devtools::install_local('/opt/SCP.zip')"
#  RUN Rscript -e 'devtools::install_github("zhanghao-njmu/SCP")'
# RUN Rscript -e 'remotes::install_github("zhanghao-njmu/SCP", dependencies = TRUE, force = TRUE)'


# Install packages on Github
RUN Rscript -e "devtools::install_github(${DEV_DEPS})"


# Create and activate virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# # Install Python packages related to cell annotation
# RUN python3 -m pip install --no-cache-dir scSpectra 
# RUN python3 -m pip install --no-cache-dir celltypist 
# RUN python3 -m pip install --no-cache-dir metatime 
# RUN python3 -m pip install --no-cache-dir session_info 
# # Set up venv and install Python packages
# RUN python3 -m venv /opt/venv \
#     && /opt/venv/bin/pip install --no-cache-dir scSpectra celltypist metatime session_info \
#     && ln -s /opt/venv/bin/python /usr/local/bin/python \
#     && ln -s /opt/venv/bin/pip /usr/local/bin/pip

    # Install Python packages for data science
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir numpy pandas scikit-learn matplotlib seaborn jupyter jupyter-cache papermill scSpectra celltypist metatime session_info \
    && ln -s /opt/venv/bin/python /usr/local/bin/python \
    && ln -s /opt/venv/bin/pip /usr/local/bin/pip

# # RUN Rscript -e "install.packages(${R_ANNOT_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)"
# RUN python3 -m venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"
# Setting celltypist variable
ENV CELLTYPIST_FOLDER=/opt/celltypist

# Installing celltypist models
COPY docker/setup.py /opt/
RUN python3 /opt/setup.py

# Install presto
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "devtools::install_github('immunogenomics/presto')"

# Install Azimuth
# RUN Rscript -e "devtools::install_github('satijalab/azimuth')"

# Set the working directory
WORKDIR /data

# Command to run on container start
CMD ["bash"]
