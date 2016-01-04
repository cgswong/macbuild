# MacBuild #

`brewsetup.sh` is a bash script to install [homebrew][homebrew] and setup your Mac OS with a list of various binaries and applications as given by the dependent configuration file `brewsetup.cfg`.

Should you want to adjust the list of binaries and/or applications that are installed the `brewsetup.cfg` configuration file can be edited with any text editor.

## How to Install  ##
Run the following commands in the terminal:

```sh
curl -O -L https://github.com/cgswong/macbuild/raw/master/brewsetup.sh
curl -O -L https://github.com/cgswong/macbuild/raw/master/brewsetup.cfg
chmod +x brewsetup.sh
./brewsetup.sh
```

[homebrew]: https://github.com/mxcl/homebrew/
