# How to run Web File Server in the Container

Assumption: you are in the *how_to_run_web_file_server_in_the_container* directory.

## How to run Web File Server in the Windows Container

Run the following, in the Windows command line.

```
docker run --rm -it -p 8080:80 -v .\iis-file-server:c:/inetpub/wwwroot mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
```

If you don't want web.config to be displayed, make it hidden.

```
attrib +H .\iis-file-server\web.config
```

## How to run Web File Server in the Linux Container

Method 1: Run the following, in the **Windows** command line.

```
docker run --rm -it -p 8080:80 -v .\nginx-file-server\nginx.conf:/etc/nginx/nginx.conf:ro -v .\nginx-file-server\html:/etc/nginx/html nginx
```

Method 2: Run the following, in the **Linux** command line (volume path for relative host directory is different).

```
docker run --rm -it -p 8080:80 -v ./nginx-file-server/nginx.conf:/etc/nginx/nginx.conf:ro -v ./nginx-file-server/html:/etc/nginx/html nginx
```

## How do I use it?

Web server is available at http://localhost:8080 and http://[your-server-ip]:8080 addresses.

## Possible issues

Pay attention to the encodings of text files (txt, html, etc.).

Search for 'utf-8' in web.config and nginx.conf files in this repository for some guidance.
