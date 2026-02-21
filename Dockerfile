FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

# Copy the project files
COPY . .

# CLEAN COMMAND: Removed --no-commit because it no longer exists in Forge
RUN forge install OpenZeppelin/openzeppelin-contracts --no-git
#RUN forge install OpenZeppelin/openzeppelin-contracts --no-git
RUN forge install foundry-rs/forge-std --no-git
# Build the project
RUN forge build

# Keep the container running
CMD ["tail", "-f", "/dev/null"]

CMD ["sleep", "infinity"]