![GitHub](https://img.shields.io/github/license/simgel/dkr-java-adoptium?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/simgel/dkr-java-adoptium?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/simgel/dkr-java-adoptium?style=for-the-badge)

## About

Java Adoptium JDK Image with nightly updates. Full JDK with a total image size of `~442MB`

## Usage

**Java 17**
```Dockerfile
FROM ghcr.io/simgel/dkr-java-adoptium:17
```

**Java 21**
```Dockerfile
FROM ghcr.io/simgel/dkr-java-adoptium:17
```


## Base Image

Based on a minimal debian base image.

```Dockerfile
FROM ghcr.io/simgel/dkr-debian-base:bookworm
````


## License

Distributed under the MIT License. See `LICENSE` for more information.


## Acknowledgments

* [adoptium](https://adoptium.net/de/)
* [Docker base image](https://github.com/simgel/dkr-debian-base)