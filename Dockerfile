FROM centos:latest

# install dependencies, e.g. gcc (here, 7), git, cmake
RUN yum -y update \
    && yum -y install centos-release-scl \
    && yum -y install devtoolset-7-gcc-c++ \
    && scl enable devtoolset-7 bash \
    && yum -y install make cmake git \
    && yum -y clean all

# change shell to bash for EDM's sake
SHELL ["/bin/bash", "--login", "-c"]

# update env to load correct binaries/libraries
RUN echo "export EDM_SHELL=bash" >> /etc/bashrc \
    && echo "export SHELL=/bin/bash" >> /etc/bashrc \
    && echo "source scl_source enable devtoolset-7" >> /etc/bashrc \
    && echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> /etc/bashrc

# download EDM and install numpy/cython and eigency into a new env
RUN curl -L https://package-data.enthought.com/edm/rh5_x86_64/1.11/edm_1.11.0_x86_64.rpm > /opt/edm.rpm \
    && yum -y install /opt/edm.rpm \
    && yes | edm install numpy --version 3.6 \
    && yum -y clean all

# download acado and compile (takes ~20 minutes)
RUN curl -L https://github.com/acado/acado/archive/v1.2.2beta.tar.gz > /opt/acado.tar.gz \
    && cd /opt/ && tar xf acado.tar.gz \
    && cd acado-1.2.2beta && mkdir build && cd build \
    && cmake .. && make && yes | make install

# clone and run acadopy installer
#RUN git clone http://github.com/ml-evs/acadopy /opt/acadopy \
    #&& cd /opt/acadopy && edm run -- python setup.py install
