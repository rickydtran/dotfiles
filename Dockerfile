ARG DISTRO=debian:latest
FROM ${DISTRO}

# Install sudo and create a user with sudo privileges
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y locales && \
    apt-get install -y git  && \
    apt-get install -y stow  && \
    apt-get install -y vim  && \
    apt-get install -y tmux  && \
    apt-get install -y curl && \
    apt-get install -y wget && \
    apt-get install -y htop && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    echo 'root ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     

WORKDIR /home/root/.dotfiles
USER ubuntu
CMD ["/bin/bash"]
