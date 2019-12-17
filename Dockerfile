# File Author / Maintainer
AUTHOR Sophie Lemoine <slemoine@biologie.ens.fr>
MAINTAINER John Karr <brainbuz@cpan.org>

# Update the repository sources list
RUN apt-get update

# Install compiler and perl stuff
RUN apt-get install --yes \
 build-essential \
 gcc-multilib \
 apt-utils \
 perl \
 expat \
 libexpat-dev 

# Install perl modules 
RUN apt-get install -y cpanminus
