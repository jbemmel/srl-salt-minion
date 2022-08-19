ARG SR_LINUX_RELEASE
FROM srl/custombase:$SR_LINUX_RELEASE AS target-image

# Upgrade system version of venv virtualenv-15.1.0 > virtualenv-20.16.3
RUN sudo pip3 install virtualenv --upgrade

# Create a Python virtual environment, note --upgrade is broken. Tried without --system-site-packages --without-pip
RUN sudo python3 -m venv /opt/srl-salt-minion/.venv --system-site-packages --without-pip
ENV VIRTUAL_ENV=/opt/srl-salt-minion/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Salt Python library and Nornir extensions for salt
# RUN sudo bash -c "source $VIRTUAL_ENV/bin/activate && python3 -m pip install salt"
RUN sudo VIRTUAL_ENV=/opt/srl-salt-minion/.venv PATH=/opt/srl-salt-minion/.venv/bin:${PATH} \
        $VIRTUAL_ENV/bin/python3 -m pip install salt nornir-salt salt-nornir

# Upgrade system version of urllib3, workaround (should be staying within virtualenv)
RUN sudo pip3 install requests urllib3 --upgrade

# Install Salt minion Python libraries
# See https://docs.saltproject.io/en/master/topics/installation/rhel.html for CENTOS 8 instructions
#RUN sudo rpm --import https://repo.saltproject.io/py3/redhat/8/x86_64/latest/SALTSTACK-GPG-KEY.pub && \
#    curl -fsSL https://repo.saltproject.io/py3/redhat/8/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt.repo && \
#    sudo yum clean expire-cache && \
#    sudo yum install -y salt-minion # salt-ssh
    # sudo yum install -y --enablerepo=extras epel-release && \

RUN sudo mkdir --mode=0755 -p /etc/opt/srlinux/appmgr/ /etc/salt/pki/minion/ /etc/salt/minion.d/ /var/cache/salt/minion/proc /var/log/salt /var/run/salt/minion && \
    sudo chown -R srlinux:srlinux /etc/salt /var/cache/salt
  # sudo chown -R srlinux:srlinux /etc/salt /var/cache/salt /var/log/salt /var/run/salt
COPY --chown=srlinux:srlinux ./srl-salt-minion.yml /etc/opt/srlinux/appmgr
COPY ./src /opt/

# Run pylint to catch any obvious errors
RUN PYTHONPATH=$AGENT_PYTHONPATH:$VIRTUAL_ENV/lib/python3.6/site-packages pylint --load-plugins=pylint_protobuf -E /opt/srl-salt-minion

# Using a build arg to set the release tag, set a default for running docker build manually
ARG SRL_SALT_MINION_RELEASE="[custom build]"
ENV SRL_SALT_MINION_RELEASE=$SRL_SALT_MINION_RELEASE
