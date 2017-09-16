# Use an official Debian runtime as a parent image
FROM debian:latest

# Set the working directory to /app
WORKDIR /app

# Copy the binary haskdragon-exe into the container at /app
ADD ./haskdragon-exe /app

# install the minimum libraries the bin will need to run
RUN DEBIAN_FRONTEND=noninteractive                    \
    apt-get -q -y update                              \
    && apt-get                                        \
      -o Dpkg::Options::="--force-confdef"            \
      -o Dpkg::Options::="--force-confold"            \
      -q -y install                                   \
      libgmp10                                        \
    && apt-get install --reinstall libffi6            \
    && apt-get clean                                  \
    && rm -rf /var/lib/apt/lists/*

# Make ports 3000 available to the world outside this container
EXPOSE 3000


# Run haskdragon-exe when the container launches
CMD ./haskdragon-exe
