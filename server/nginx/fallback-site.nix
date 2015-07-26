# Module containing a default "fallback site" for nginx which is served when no
# other site in the configuration file can fulfil a request.
{ config, pkgs, lib, ... }:

with lib;

let
  nginxDefaultPage = pkgs.writeTextDir "nginx-default-site.html" ''
    <!DOCTYPE html>
    <html>
      <head>
        <title>Hello World</title>
        <meta charset="utf-8">
      </head>

      <body>
        <h1>There's nothing here!</h1>
        <p>This is the default site for this webserver. You are seeing this page
        because the webserver couldn't find another site configured to handle
        this address.</p>
        <p>If you're getting this page after going to an address that probably
        should have something hosted on it (like forkk.net), then please contact
        Forkk ASAP.</p>
        <p>Below is a list of some of the things hosted on this server. I hope
        you find what you were looking for.</p>
        <ul>
          <li><a href="http://forkk.net">
            forkk.net &mdash; Forkk's website/blog
          </a></li>
          <li><a href="http://siteci.forkk.net">
            siteci.forkk.net &mdash; Buildbot CI server for the above blog
          </li></a>
        </ul>
      </body>
    </html>
  '';

  nginxDefaultSite = ''
    server
    {
      server_name _;

      root ${nginxDefaultPage};

      location /nginx-default-site.html {
        try_files $uri =404;
      }

      location / {
        rewrite ^ /nginx-default-site.html break;
      }
    }
  '';
in
{
  services.nginx.sites = [ nginxDefaultSite ];
}
