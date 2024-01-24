FROM --platform=linux/amd64 debian:bookworm-slim
# updating, upgrading, and installing software
RUN apt update && apt upgrade
RUN apt-get install -y \
    build-essential \
    unzip \
    git \
    curl \
    wget \
    make \
    ruby \
    bash \
    exa \
    bat \
    vim \
    tmux \
    fzf \
    sudo \
    zsh
RUN apt-get clean autoclean
RUN apt-get autoremove --yes
RUN rm -rf /var/lib/{apt,dpkg,cache,log}
# setting up user
ARG USER=developer
ENV HOME /home/$USER
RUN touch /etc/sudoers.d/$USER
RUN adduser --disabled-password --gecos "" $USER \
        && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER
# installing fnm
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "${HOME}/.fnm" --skip-shell
RUN chown -R $USER /home/developer/.fnm
# installing starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
# installing neovim
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
RUN tar xzvf nvim-linux64.tar.gz
RUN mv ./nvim-linux64/bin/nvim /usr/local/bin/nvim
RUN rm -rf nvim-linux64.tar.gz nvim-linux64
# cleaning up
RUN chown -R $USER /home/developer/.cache
# switching to user
USER $USER
WORKDIR $HOME
# installing zsh and other plugins, cloning dotfiles
RUN git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-history-substring-search $HOME/.zsh/zsh-history-substring-search
RUN git clone https://github.com/zdharma-continuum/fast-syntax-highlighting $HOME/.zsh/fsh
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
RUN git clone --branch local https://github.com/d-mv/dotfiles $HOME/.dotfiles
# linking dotfiles
RUN mkdir -p $HOME/.config
RUN touch /home/developer/.dotfiles/zsh/private.zsh
RUN ln -s $HOME/.dotfiles/zsh/zshrc $HOME/.zshrc
RUN ln -s $HOME/.dotfiles/starship.toml $HOME/.config/starship.toml
RUN ln -s $HOME/.dotfiles/git/.gitconfig $HOME/.gitconfig
RUN ln -s $HOME/.dotfiles/.gitignore $HOME/.gitignore
RUN ln -s $HOME/.dotfiles/tmux/tmux.conf $HOME/.tmux.conf
RUN ln -s $HOME/.dotfiles/nvim $HOME/.config/nvim
# installing additionals
RUN ${HOME}/.fnm/fnm install 20
# connecting
ENTRYPOINT ["/bin/zsh"]
