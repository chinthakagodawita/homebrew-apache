require "formula"

class ModFastcgi < Formula
  url "http://www.fastcgi.com/dist/mod_fastcgi-2.4.6.tar.gz"
  homepage "http://www.fastcgi.com/"
  sha1 "69c56548bf97040a61903b32679fe3e3b7d3c2d4"

  bottle do
    cellar :any
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "a811075107ca5337d0553cd57d2e780d5238f7b2" => :snow_leopard
    sha1 "44fa0418a50e540ca1478d5ca4df074c2370ac14" => :lion
    sha1 "d8d243e599192134fdfa1ba09b5a31721decfd37" => :mountain_lion
    sha1 "e87c8b9e193fedd0ba67a1bedab14133267e728f" => :mavericks
  end

  option "with-brewed-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-brewed-httpd24", "Use Homebrew Apache httpd 2.4"

  depends_on "httpd22" if build.with? "brewed-httpd22"
  depends_on "httpd24" if build.with? "brewed-httpd24"

  if build.with? "brewed-httpd22" and build.with? "brewed-httpd24"
    onoe "Cannot build for http22 and httpd24 at the same time"
    exit 1
  end

  if (! (build.with? "brewed-httpd22" or build.with? "brewed-httpd24")) and MacOS.version == :mavericks
    unless system("pkgutil --pkgs | grep -qx com.apple.pkg.CLTools_Executables")
      onoe "Command Line Tools required, even if Xcode is installed, on 10.9 Mavericks and not
       using Homebrew httpd22 or httpd24. Resolve by running `xcode-select --install`."
      exit 1
    end
  end

  def apache_apxs
    if build.with? "brewed-httpd22"
      %W[sbin, bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? "brewed-httpd24"
      %W[sbin, bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      "/usr/sbin/apxs"
    end
  end

  def apache_configdir
    if build.with? "brewed-httpd22"
      "#{etc}/apache2/2.2"
    elsif build.with? "brewed-httpd24"
      "#{etc}/apache2/2.4"
    else
      "/etc/apache2"
    end
  end

  if (MacOS.version == :yosemite or build.with? "brewed-httpd24")
    patch do
      url "https://raw.githubusercontent.com/ByteInternet/libapache-mod-fastcgi/byte/debian/patches/byte-compile-against-apache24.diff"
      sha1 "1000fac5bf814d716641bbd1528de34449049a73"
    end
  end

  def install
    system "#{apache_apxs} -o mod_fastcgi.so -c *.c"
    libexec.install ".libs/mod_fastcgi.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to contain:
      LoadModule fastcgi_module #{libexec}/mod_fastcgi.so

    Upon restarting Apache, you should see the following message in the error log:
      [notice] FastCGI: process manager initialized

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
