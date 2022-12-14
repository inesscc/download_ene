# start by pulling the python image
#FROM python:3.8-alpine
FROM python:3.9

# Install R

ENV R_BASE_VERSION 4.1.0

# During the freeze, new (source) packages are in experimental and we place the binaries in our PPA
RUN echo "deb http://deb.debian.org/debian experimental main" > /etc/apt/sources.list.d/experimental.list \
    && echo "deb [trusted=yes] https://eddelbuettel.github.io/ppaR400 ./" > /etc/apt/sources.list.d/edd-r4.list

# Now install R and littler, and create a link for littler in /usr/local/bin
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                libopenblas0-pthread \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}-* \
		r-base-dev=${R_BASE_VERSION}-* \
                r-base-core=${R_BASE_VERSION}-* \
		r-recommended=${R_BASE_VERSION}-* \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installDeps.r /usr/local/bin/installDeps.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*

# Install nano
RUN apt-get update -y && apt-get -y install nano 

# Install Java
RUN apt-get update -y &&  apt-get -y install default-jdk

# Install renv
ENV RENV_VERSION 0.16.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"


# switch working directory
WORKDIR /app


# copy every content from the local file to the image
COPY . /app

# Install R packages
ENV RENV_PATHS_LIBRARY renv/library
RUN Rscript -e "renv::restore()"

# Install cron and jobs
RUN apt-get update -y && apt-get -y install cron
RUN echo "*/2 * * * * cd /app && Rscript /app/code/download_last_ene_data.R /app/data/ /app/data/ TRUE" > /etc/cron.d/download-data
RUN echo "" >> /etc/cron.d/download-data 
RUN chmod 0644 /etc/cron.d/download-data
RUN crontab /etc/cron.d/download-data


# configure the container to run in an executed manner
#ENTRYPOINT [ "python" ]

CMD ["cron", "-f" ]

